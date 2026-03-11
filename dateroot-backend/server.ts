import express from "express";
import type { Request, Response } from "express"; 
import http from "http";
import { Server, Socket } from "socket.io";
import cors from "cors";
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
// @ts-ignore
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { Pool } from 'pg'; 
import * as dotenv from 'dotenv';
import bcrypt from 'bcrypt';

dotenv.config();

const app = express();
const server = http.createServer(app);

app.use(cors());
app.use(express.json());

app.use((req, res, next) => {
  console.log(`[${req.method}] request received at: ${req.url}`);
  next();
});

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://postgres:YOUR_DB_PASSWORD@127.0.0.1:5432/dateroot',
  connectionTimeoutMillis: 5000, 
});

pool.connect((err, client, release) => {
  if (err) {
    console.error('DATABASE CONNECTION FAILED. Is PostgreSQL running?', err.message);
  } else {
    console.log('DATABASE CONNECTED SUCCESSFULLY');
    release();
  }
});

const io = new Server(server, {
  cors: {
    origin: "*", 
    methods: ["GET", "POST"]
  }
});

const s3 = new S3Client({
  region: 'auto',
  endpoint: `https://9751fff4aee9e644766dfa510fedd00f.r2.cloudflarestorage.com`,
  credentials: {
    accessKeyId: 'c1ba1c54e0b5b6595eba808f6fdc23e1',
    secretAccessKey: 'e3332852e869d466f7bb50152adc1b2ddd148b14cf682e0e5544986fc5ddeb16',
  },
});

interface UserUpdatePayload {
    userId: string;
    imageUrl: string;
}

interface ReportPayload {
    reporterId: string;
    reportedId: string;
    reason: string;
}

interface BlockPayload {
    blockerId: string;
    blockedId: string;
}

app.post('/api/auth/login', async (req: Request, res: Response) => {
  const { email, password } = req.body;
  
  if (!email || !password) {
    return res.status(400).json({ error: "Email and password required" });
  }

  try {
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    
    if (result.rows.length === 0) {
      return res.status(401).json({ error: "User not found" });
    }

    const user = result.rows[0];
    const dbPassword = user.password || user.password_hash; 
    
    if (!dbPassword) {
      return res.status(401).json({ error: "This user has no password set in the database." });
    }

    let isValid = false;
    const dbPasswordStr = String(dbPassword);
    
    if (dbPasswordStr.startsWith('$2b$') || dbPasswordStr.startsWith('$2a$')) {
      isValid = await bcrypt.compare(password, dbPasswordStr); 
    } else {
      isValid = (password === dbPasswordStr);
    }

    if (!isValid) {
      return res.status(401).json({ error: "Wrong password" });
    }

    res.json({ success: true, user: user });
  } catch (error) {
    console.error("Login Error:", error);
    res.status(500).json({ error: "Server crashed during login" });
  }
});

app.get('/api/get-upload-url', async (req: Request, res: Response) => {
  try {
    const fileName = `profile_${Date.now()}_${Math.floor(Math.random() * 10000)}.webp`;

    const command = new PutObjectCommand({
      Bucket: 'imagespic', 
      Key: fileName,
      ContentType: 'image/webp',
    });

    const signedUrl = await getSignedUrl(s3, command, { expiresIn: 60 });

    res.json({
      uploadUrl: signedUrl,
      publicUrl: `https://pub-81adeabdbbcb419b8ae16577a69f4404.r2.dev/${fileName}` 
    });

  } catch (error) {
    console.error("Error generating R2 URL:", error);
    res.status(500).json({ error: "Failed to generate upload URL" });
  }
});

app.get('/api/users', async (req: Request, res: Response) => {
  try {
    const query = `
      SELECT u.*, 
      COALESCE(
        (SELECT json_agg(image_url) FROM gallery_images WHERE user_id = u.id), 
        '[]'
      ) AS gallery
      FROM users u
      ORDER BY u.created_at DESC
    `;
    const result = await pool.query(query);
    res.json(result.rows);
  } catch (err: any) {
    console.error("Fetch Users Error:", err);
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/users/update-image', async (req: Request, res: Response) => {
  const { userId, imageUrl } = req.body as UserUpdatePayload;
  const userIp = req.headers['x-forwarded-for'] || req.socket.remoteAddress;
  
  if (!userId || !imageUrl) {
    return res.status(400).json({ error: "Missing userId or imageUrl" });
  }

  try {
    await pool.query(
      'UPDATE users SET image = $1, last_ip = $2 WHERE id = $3', 
      [imageUrl, userIp, userId]
    );
    res.json({ success: true, message: "Database updated with new image and IP", ip: userIp });
  } catch (error) {
    console.error("DB Update Error:", error);
    res.status(500).json({ error: "Failed to update database" });
  }
});

app.post('/api/gallery/add', async (req: Request, res: Response) => {
  const { userId, imageUrl } = req.body as UserUpdatePayload;
  try {
    await pool.query(
      'INSERT INTO gallery_images (user_id, image_url, created_at) VALUES ($1, $2, NOW())', 
      [userId, imageUrl]
    );
    res.json({ success: true });
  } catch (err: any) {
    console.error("Gallery Add Error:", err);
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/gallery/remove', async (req: Request, res: Response) => {
  const { userId, imageUrl } = req.body as UserUpdatePayload;
  try {
    await pool.query(
      'DELETE FROM gallery_images WHERE user_id = $1 AND image_url = $2', 
      [userId, imageUrl]
    );
    res.json({ success: true });
  } catch (err: any) {
    console.error("Gallery Remove Error:", err);
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/admin/action', async (req: Request, res: Response) => {
  const { action, target_id } = req.body;
  try {
    if (action === 'wipe_lobby') {
      await pool.query('DELETE FROM lobby_messages');
      return res.json({ success: true });
    }
    
    if (action === 'wipe_private') {
      await pool.query('DELETE FROM private_messages');
      return res.json({ success: true });
    }
    
    if (action === 'ban_user') {
      await pool.query('UPDATE users SET is_banned = true WHERE id = $1', [target_id]);
      return res.json({ success: true });
    }
    
    if (action === 'unban_user') {
      await pool.query('UPDATE users SET is_banned = false WHERE id = $1', [target_id]);
      return res.json({ success: true });
    }
    
    if (action === 'block_ip') {
      const userRes = await pool.query('SELECT last_ip FROM users WHERE id = $1', [target_id]);
      
      if (userRes.rows.length > 0 && userRes.rows[0].last_ip) {
        const targetIp = userRes.rows[0].last_ip;
        
        try {
          await pool.query(`
            INSERT INTO banned_ips (ip_address) 
            VALUES ($1) 
            ON CONFLICT DO NOTHING
          `, [targetIp]);
        } catch (ignoreErr) { 
          console.log("Note: Could not insert into banned_ips.", ignoreErr); 
        }
      }
      
      await pool.query('UPDATE users SET is_banned = true WHERE id = $1', [target_id]);
      return res.json({ success: true });
    }
    
    if (action === 'unblock_ip') {
      const userRes = await pool.query('SELECT last_ip FROM users WHERE id = $1', [target_id]);
      
      if (userRes.rows.length > 0 && userRes.rows[0].last_ip) {
        try {
          await pool.query('DELETE FROM banned_ips WHERE ip_address = $1', [userRes.rows[0].last_ip]);
        } catch (ignoreErr) {}
      }
      
      await pool.query('UPDATE users SET is_banned = false WHERE id = $1', [target_id]);
      return res.json({ success: true });
    }
    
    if (action === 'delete_user') {
      await pool.query('DELETE FROM users WHERE id = $1', [target_id]);
      return res.json({ success: true });
    }
    
    res.json({ success: true });
  } catch (error) {
    console.error("Admin Action Error:", error);
    res.status(500).json({ error: "Failed to execute admin action" });
  }
});

app.post('/api/admin/resolve-report', async (req: Request, res: Response) => {
  const { reportId } = req.body;
  try {
    await pool.query('DELETE FROM reports WHERE id = $1', [reportId]);
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: "Failed to resolve report" });
  }
});

app.post('/api/block', async (req: Request, res: Response) => {
  const { blockerId, blockedId } = req.body as BlockPayload;
  try {
    await pool.query(
      'INSERT INTO blocks (blocker_id, blocked_id, created_at) VALUES ($1, $2, NOW())',
      [blockerId, blockedId]
    );
    res.json({ success: true, message: "User blocked successfully" });
  } catch (error) {
    res.status(500).json({ error: "Failed to block user" });
  }
});

app.post('/api/report', async (req: Request, res: Response) => {
  const { reporterId, reportedId, reason } = req.body as ReportPayload;
  try {
    await pool.query(
      'INSERT INTO reports (reporter_id, reported_id, reason, created_at) VALUES ($1, $2, $3, NOW())',
      [reporterId, reportedId, reason]
    );
    res.json({ success: true, message: "Report sent" });
  } catch (error) {
    res.status(500).json({ error: "Failed to report user" });
  }
});

app.get('/api/admin/reports', async (req: Request, res: Response) => {
  try {
    const result = await pool.query("SELECT * FROM reports WHERE status = 'pending' ORDER BY created_at DESC");
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch reports" });
  }
});

app.get('/api/admin/ip-logs', async (req: Request, res: Response) => {
    try {
      const result = await pool.query('SELECT name, email, last_ip, created_at FROM users WHERE last_ip IS NOT NULL');
      res.json(result.rows);
    } catch (error) {
      res.status(500).json({ error: "Could not fetch IP logs" });
    }
});

app.post('/api/likes', async (req: Request, res: Response) => {
  const { user_id, liked_user_id } = req.body;
  if (!user_id || !liked_user_id) return res.status(400).json({ error: "Missing IDs" });
  try {
    const existing = await pool.query('SELECT * FROM likes WHERE user_id = $1 AND liked_user_id = $2', [user_id, liked_user_id]);
    if (existing.rows.length > 0) {
      await pool.query('DELETE FROM likes WHERE user_id = $1 AND liked_user_id = $2', [user_id, liked_user_id]);
    } else {
      await pool.query('INSERT INTO likes (user_id, liked_user_id) VALUES ($1, $2)', [user_id, liked_user_id]);
    }
    res.json({ success: true });
  } catch (error) {
    console.error("Likes Error:", error);
    res.status(500).json({ error: "Failed to toggle like" });
  }
});

app.get('/api/likes/my-likes', async (req: Request, res: Response) => {
  try {
    const result = await pool.query('SELECT liked_user_id FROM likes WHERE user_id = $1', [req.query.my_id]);
    res.json(result.rows.map(r => r.liked_user_id));
  } catch (error) {
    console.error("Fetch Likes Error:", error);
    res.json([]);
  }
});

app.get('/api/likes/who-liked-me', (req: Request, res: Response) => res.json([]));
app.get('/api/views', (req: Request, res: Response) => res.json([]));
app.get('/api/gifts', (req: Request, res: Response) => res.json([]));

app.get('/api/lobby', async (req: Request, res: Response) => {
  try {
    const result = await pool.query(`
      SELECT l.id, u.name as user, l.content as text, l.created_at
      FROM lobby_messages l
      JOIN users u ON l.sender_id = u.id
      ORDER BY l.created_at DESC LIMIT 50
    `);
    
    const formatted = result.rows.reverse().map(row => {
      const safeDate = row.created_at ? new Date(row.created_at) : new Date();
      return {
        id: row.id.toString(), 
        user: row.user,
        text: row.text,
        time: safeDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
      };
    });
    
    res.json(formatted);
  } catch (error) {
    res.json([]);
  }
});

app.post('/api/lobby', async (req: Request, res: Response) => {
  const { sender_id, content } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO lobby_messages (sender_id, content, created_at) VALUES ($1, $2, NOW()) RETURNING id',
      [sender_id, content]
    );
    res.json({ success: true, id: result.rows[0].id.toString(), time: new Date().toLocaleTimeString() });
  } catch (error) {
    res.status(500).json({ error: "Failed to process lobby message" });
  }
});

app.get('/api/messages', async (req: Request, res: Response) => {
  const myId = req.query.my_id as string;
  const otherId = req.query.other_id as string;
  try {
    if (!myId) return res.json(otherId ? [] : {});
    
    if (otherId) {
      const result = await pool.query(`
        SELECT id, content as text, sender_id, receiver_id, created_at
        FROM private_messages
        WHERE (sender_id = $1 AND receiver_id = $2) OR (sender_id = $2 AND receiver_id = $1)
        ORDER BY created_at ASC
      `, [myId, otherId]);
      
      const formatted = result.rows.map(row => ({
        _id: row.id.toString(), 
        id: row.id.toString(), 
        text: row.text,
        sender: row.sender_id === myId ? 'me' : 'other',
        createdAt: row.created_at ? new Date(row.created_at).getTime() : Date.now() 
      }));
      return res.json(formatted);
      
    } else {
      const result = await pool.query(`
        SELECT id, content as text, sender_id, receiver_id, created_at
        FROM private_messages WHERE sender_id = $1 OR receiver_id = $1
        ORDER BY created_at ASC
      `, [myId]);

      const grouped: Record<string, any[]> = {};
      result.rows.forEach(row => {
        const oId = row.sender_id === myId ? row.receiver_id : row.sender_id;
        if (!grouped[oId]) grouped[oId] = [];
        
        grouped[oId].push({
          _id: row.id.toString(), 
          id: row.id.toString(), 
          text: row.text,
          sender: row.sender_id === myId ? 'me' : 'other',
          createdAt: row.created_at ? new Date(row.created_at).getTime() : Date.now() 
        });
      });
      return res.json(grouped);
    }
  } catch (error) {
    console.error("Messages GET Error:", error);
    res.json(otherId ? [] : {}); 
  }
});

app.post('/api/messages', async (req: Request, res: Response) => {
  const { sender_id, receiver_id, content } = req.body;
  try {
    await pool.query(
      'INSERT INTO private_messages (sender_id, receiver_id, content, created_at) VALUES ($1, $2, $3, NOW())',
      [sender_id, receiver_id, content]
    );
    res.json({ success: true });
  } catch (error) {
    console.error("Private Message POST Error:", error);
    res.status(500).json({ error: "Failed to process private message" });
  }
});

io.on("connection", (socket: Socket) => {
  console.log("Connected:", socket.id);

  socket.on("send_lobby_msg", (data: any) => {
    socket.broadcast.emit("receive_lobby_msg", data);
  });

  socket.on("register_user", (userData: any) => {
    if (typeof userData === 'string') {
      socket.join(userData);
    } 
    else if (userData && userData.id) {
      socket.join(userData.id);    
      socket.join(userData.name);  
      console.log(`User ID: ${userData.id} registered for private routing.`);
    }
  });

  socket.on("private_message", ({ receiverId, messageData }: any) => {
    socket.to(receiverId).emit("receive_private_msg", messageData);
  });

  socket.on("start_call", (data: any) => {
    socket.to(data.receiverId).emit("incoming_call", {
      callerId: data.callerId,
      callerName: data.callerName,
      cloudflareSessionId: data.cloudflareSessionId
    });
  });

  socket.on("decline_call", (data: any) => {
    socket.to(data.callerId).emit("call_declined");
  });

  socket.on("disconnect", () => {
    console.log("User disconnected:", socket.id);
  });
});

const PORT = 3001; 
server.listen(PORT, '0.0.0.0', () => {
  console.log(`DateRoot TS Server running on http://0.0.0.0:${PORT}`);
});