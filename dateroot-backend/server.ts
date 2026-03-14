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

// ==========================================================
// ⚙️ ENVIRONMENT & SERVER SETUP
// ==========================================================
dotenv.config();

const app = express();
const server = http.createServer(app);

app.use(cors());
app.use(express.json());

// Request Logging Middleware
app.use((req: Request, res: Response, next: Function) => {
  console.log(`[${req.method}] request received at: ${req.url}`);
  next();
});

// ==========================================================
// 🗄️ DATABASE CONNECTION & AUTO-SETUP
// ==========================================================
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://postgres:YOUR_DB_PASSWORD@127.0.0.1:5432/dateroot',
  connectionTimeoutMillis: 5000, 
});

pool.connect(async (err: any, client: any, release: any) => {
  if (err) {
    console.error('DATABASE CONNECTION FAILED. Is PostgreSQL running?', err.message);
  } else {
    console.log('DATABASE CONNECTED SUCCESSFULLY');
    
    // 🚀 SAFETY: AUTO-CREATE MISSING TABLES FOR GIFTS AND PENDING FRIENDS 🚀
    try {
      await client.query(`
        CREATE TABLE IF NOT EXISTS gifts (
          id SERIAL PRIMARY KEY,
          sender_id VARCHAR(255),
          receiver_id VARCHAR(255),
          gift_name VARCHAR(255),
          created_at TIMESTAMP DEFAULT NOW()
        );

        CREATE TABLE IF NOT EXISTS friends (
          id SERIAL PRIMARY KEY,
          user_id VARCHAR(255),
          friend_id VARCHAR(255),
          status VARCHAR(50) DEFAULT 'pending',
          created_at TIMESTAMP DEFAULT NOW(),
          UNIQUE(user_id, friend_id)
        );
      `);

      // If the friends table already exists but lacks the 'status' column, add it safely
      await client.query(`
        ALTER TABLE friends 
        ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'pending';
      `);

      console.log('Verified gifts and friends tables.');
    } catch (e) {
      console.error("Could not auto-verify tables:", e);
    }
    
    release();
  }
});

// ==========================================================
// 🔌 SOCKET.IO & S3 SETUP
// ==========================================================
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

// ==========================================================
// 📋 TYPES AND INTERFACES
// ==========================================================
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

// ==========================================================
// 🔐 AUTHENTICATION
// ==========================================================
app.post('/api/auth/login', async (req: Request, res: Response) => {
  const { email, password } = req.body;
  
  if (!email || !password) {
    return res.status(400).json({ 
      error: "Email and password required" 
    });
  }

  try {
    const result = await pool.query(
      'SELECT * FROM users WHERE email = $1', 
      [email]
    );
    
    if (result.rows.length === 0) {
      return res.status(401).json({ 
        error: "User not found" 
      });
    }

    const user = result.rows[0];
    const dbPassword = user.password || user.password_hash; 
    
    if (!dbPassword) {
      return res.status(401).json({ 
        error: "This user has no password set in the database." 
      });
    }

    let isValid = false;
    const dbPasswordStr = String(dbPassword);
    
    if (dbPasswordStr.startsWith('$2b$') || dbPasswordStr.startsWith('$2a$')) {
      isValid = await bcrypt.compare(password, dbPasswordStr); 
    } else {
      isValid = (password === dbPasswordStr);
    }

    if (!isValid) {
      return res.status(401).json({ 
        error: "Wrong password" 
      });
    }

    res.json({ 
      success: true, 
      user: user 
    });
  } catch (error) {
    console.error("Login Error:", error);
    res.status(500).json({ 
      error: "Server crashed during login" 
    });
  }
});

// ==========================================================
// ☁️ UPLOADS (CLOUDFLARE R2 S3)
// ==========================================================
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
    res.status(500).json({ 
      error: "Failed to generate upload URL" 
    });
  }
});

// ==========================================================
// 🌍 USER ROUTES (DISCOVERY FEED WITH PENDING FRIENDS/GIFTS)
// ==========================================================
app.get('/api/users', async (req: Request, res: Response) => {
  const myId = req.query.my_id as string;
  
  // 🚀 ŠTIT 1: Sprečava da "test_user_id" sruši bazu
  if (!myId || myId === 'test_user_id' || myId === 'undefined') {
      return res.json([]);
  }
  
  try {
    let query = '';
    let params: any[] = [];
    
    const selectFields = `
      SELECT u.*, 
      COALESCE(
        (SELECT json_agg(image_url) FROM gallery_images WHERE user_id = u.id), 
        '[]'
      ) AS gallery,
      
      COALESCE(
        (SELECT json_agg(json_build_object('id', u2.id, 'name', u2.name, 'image', u2.image)) 
         FROM friends f 
         JOIN users u2 ON (f.friend_id = u2.id OR f.user_id = u2.id) 
         WHERE (f.user_id = u.id OR f.friend_id = u.id) 
           AND u2.id != u.id 
           AND f.status = 'accepted'), 
        '[]'
      ) AS friends,

      COALESCE(
        (SELECT json_agg(json_build_object('id', u2.id, 'name', u2.name, 'image', u2.image)) 
         FROM friends f 
         JOIN users u2 ON f.friend_id = u2.id 
         WHERE f.user_id = u.id AND f.status = 'pending'), 
        '[]'
      ) AS sent_requests,

      COALESCE(
        (SELECT json_agg(json_build_object('id', u1.id, 'name', u1.name, 'image', u1.image)) 
         FROM friends f 
         JOIN users u1 ON f.user_id = u1.id 
         WHERE f.friend_id = u.id AND f.status = 'pending'), 
        '[]'
      ) AS received_requests,

      COALESCE(
        (SELECT json_agg(json_build_object('id', g.id, 'gift_name', g.gift_name, 'sender_id', g.sender_id)) 
         FROM gifts g WHERE g.receiver_id = u.id), 
        '[]'
      ) AS gifts
      FROM users u
    `;

    if (myId) {
      query = `
        ${selectFields}
        WHERE u.id NOT IN (
            SELECT blocked_id FROM blocks WHERE blocker_id = $1
            UNION
            SELECT blocker_id FROM blocks WHERE blocked_id = $1
        )
        ORDER BY u.created_at DESC
      `;
      params = [myId];
    } else {
      query = `
        ${selectFields}
        ORDER BY u.created_at DESC
      `;
    }
    
    const result = await pool.query(query, params);
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
    res.json({ 
      success: true, 
      message: "Database updated with new image and IP", 
      ip: userIp 
    });
  } catch (error) {
    console.error("DB Update Error:", error);
    res.status(500).json({ error: "Failed to update database" });
  }
});

app.post('/api/users/update-profile', async (req: Request, res: Response) => {
  const { 
    userId, name, bio, hereFor, city, country, music, education, 
    sexuality, bodyType, hairColor, eyeColor, weight, height, 
    day, month, year 
  } = req.body;

  if (!userId) {
    return res.status(400).json({ error: "Missing userId" });
  }

  try {
    const updateQuery = `
      UPDATE users 
      SET 
        name = $1, 
        bio = $2, 
        here_for = $3,
        city = $4, 
        country = $5, 
        music = $6, 
        education = $7, 
        sexuality = $8, 
        body_type = $9, 
        hair_color = $10, 
        eye_color = $11, 
        weight = $12, 
        height = $13, 
        dob_day = $14, 
        dob_month = $15, 
        dob_year = $16
      WHERE id = $17
      RETURNING *;
    `;

    const values = [
      name || null, bio || null, hereFor || null, city || null, country || null, 
      music || null, education || null, sexuality || null, bodyType || null, 
      hairColor || null, eyeColor || null, weight || null, height || null, 
      day || null, month || null, year || null, userId
    ];

    const result = await pool.query(updateQuery, values);

    if (result.rowCount === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    res.json({ success: true, message: "Profile updated successfully" });
  } catch (error: any) {
    console.error("Profile Update Error:", error);
    res.status(500).json({ 
      error: "Failed to update profile", 
      details: error.message 
    });
  }
});

// ==========================================================
// 🖼️ GALLERY ROUTES
// ==========================================================
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

// ==========================================================
// 🛠️ ADMIN DASHBOARD ROUTES
// ==========================================================
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
          await pool.query(
            `INSERT INTO banned_ips (ip_address) VALUES ($1) ON CONFLICT DO NOTHING`, 
            [targetIp]
          );
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
          await pool.query(
            'DELETE FROM banned_ips WHERE ip_address = $1', 
            [userRes.rows[0].last_ip]
          );
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

app.get('/api/admin/reports', async (req: Request, res: Response) => {
  try {
    const result = await pool.query(`
      SELECT 
        r.id, 
        r.reporter_id, 
        r.reported_id, 
        r.reason, 
        r.status, 
        r.created_at, 
        u1.name AS reporter_name, 
        u2.name AS reported_name 
      FROM reports r 
      LEFT JOIN users u1 ON r.reporter_id = u1.id 
      LEFT JOIN users u2 ON r.reported_id = u2.id 
      WHERE r.status = 'pending' OR r.status IS NULL
      ORDER BY r.created_at DESC
    `);
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch reports" });
  }
});

app.get('/api/admin/ip-logs', async (req: Request, res: Response) => {
    try {
      const result = await pool.query(
        'SELECT name, email, last_ip, created_at FROM users WHERE last_ip IS NOT NULL'
      );
      res.json(result.rows);
    } catch (error) {
      res.status(500).json({ error: "Could not fetch IP logs" });
    }
});

// ==========================================================
// 🚫 BLOCKING AND REPORTING ROUTES
// ==========================================================
app.post('/api/block', async (req: Request, res: Response) => {
  const { blockerId, blockedId } = req.body as BlockPayload;
  try {
    await pool.query(
      `INSERT INTO blocks (blocker_id, blocked_id, created_at) 
       VALUES ($1, $2, NOW()) 
       ON CONFLICT DO NOTHING`,
      [blockerId, blockedId]
    );
    res.json({ success: true, message: "User blocked successfully" });
  } catch (error) {
    res.status(500).json({ error: "Failed to block user" });
  }
});

app.post('/api/unblock', async (req: Request, res: Response) => {
  const { blockerId, blockedId } = req.body as BlockPayload;
  try {
    await pool.query(
      'DELETE FROM blocks WHERE blocker_id = $1 AND blocked_id = $2',
      [blockerId, blockedId]
    );
    res.json({ success: true, message: "User unblocked successfully" });
  } catch (error) {
    res.status(500).json({ error: "Failed to unblock user" });
  }
});

app.get('/api/blocks/:userId', async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;
    const result = await pool.query(`
      SELECT u.id, u.name, u.image 
      FROM blocks b 
      JOIN users u ON b.blocked_id = u.id 
      WHERE b.blocker_id = $1
    `, [userId]);
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch blocked users" });
  }
});

app.post('/api/report', async (req: Request, res: Response) => {
  const { reporterId, reportedId, reason } = req.body as ReportPayload;
  try {
    await pool.query(
      `INSERT INTO reports (reporter_id, reported_id, reason, status, created_at) 
       VALUES ($1, $2, $3, 'pending', NOW())`,
      [reporterId, reportedId, reason]
    );
    res.json({ success: true, message: "Report sent" });
  } catch (error) {
    console.error("Report Error:", error);
    res.status(500).json({ error: "Failed to report user" });
  }
});

// ==========================================================
// ❤️ INTERACTIONS (LIKES, VIEWS, GIFTS, FRIENDS)
// ==========================================================

// 🚀 RUTINE KOJE SU FALILE U TVOM STAROM KODU 🚀
app.get('/api/notifications', async (req: Request, res: Response) => {
  res.json([]); // Ovo mora da postoji da aplikacija ne baca 404 grešku
});

app.post('/api/likes', async (req: Request, res: Response) => {
  const { user_id, liked_user_id } = req.body;
  
  if (!user_id || !liked_user_id) {
    return res.status(400).json({ error: "Missing IDs" });
  }

  try {
    const existing = await pool.query(
      'SELECT * FROM likes WHERE user_id = $1 AND liked_user_id = $2', 
      [user_id, liked_user_id]
    );

    if (existing.rows.length > 0) {
      await pool.query(
        'DELETE FROM likes WHERE user_id = $1 AND liked_user_id = $2', 
        [user_id, liked_user_id]
      );
    } else {
      await pool.query(
        'INSERT INTO likes (user_id, liked_user_id) VALUES ($1, $2)', 
        [user_id, liked_user_id]
      );

      const userRes = await pool.query('SELECT name FROM users WHERE id = $1', [user_id]);
      const likerName = userRes.rows[0]?.name || 'Someone';

      io.to(liked_user_id).emit("new_notification", {
        id: `like_${Date.now()}`,
        type: "like",
        message: `${likerName} liked your profile!`,
        created_at: new Date().toISOString(),
        is_read: false
      });
    }
    res.json({ success: true });
  } catch (error) {
    console.error("Likes Error:", error);
    res.status(500).json({ error: "Failed to toggle like" });
  }
});

app.get('/api/likes/my-likes', async (req: Request, res: Response) => {
  const myId = req.query.my_id as string;
  // 🚀 ŠTIT 2: Sprečava da "test_user_id" sruši bazu
  if (!myId || myId === 'test_user_id' || myId === 'undefined') return res.json([]);

  try {
    const result = await pool.query(
      'SELECT liked_user_id FROM likes WHERE user_id = $1', 
      [myId]
    );
    res.json(result.rows.map(r => r.liked_user_id));
  } catch (error) {
    res.json([]);
  }
});

app.get('/api/likes/who-liked-me', async (req: Request, res: Response) => {
  res.json([]);
});

app.get('/api/views', async (req: Request, res: Response) => {
  res.json([]);
});

app.post('/api/views', async (req: Request, res: Response) => {
  res.json({ success: true });
});

// 🚀 FRIENDS: SEND REQUEST 🚀
app.post('/api/friends', async (req: Request, res: Response) => {
  const { user_id, friend_id } = req.body;
  try {
    await pool.query(
      `INSERT INTO friends (user_id, friend_id, status, created_at) 
       VALUES ($1, $2, 'pending', NOW()) 
       ON CONFLICT (user_id, friend_id) 
       DO UPDATE SET status = 'pending'`,
      [user_id, friend_id]
    );

    const userRes = await pool.query('SELECT name FROM users WHERE id = $1', [user_id]);
    const senderName = userRes.rows[0]?.name || 'Someone';

    io.to(friend_id).emit("new_notification", {
      id: `req_${Date.now()}`,
      type: "friend_request",
      message: `${senderName} sent you a friend request!`,
      created_at: new Date().toISOString(),
      is_read: false
    });

    res.json({ success: true, message: "Friend request sent" });
  } catch (error) {
    console.error("Friend Error:", error);
    res.status(500).json({ error: "Failed to send friend request" });
  }
});

// 🚀 FRIENDS: ACCEPT REQUEST 🚀
app.post('/api/friends/accept', async (req: Request, res: Response) => {
  const { user_id, friend_id } = req.body;
  try {
    await pool.query(
      "UPDATE friends SET status = 'accepted' WHERE user_id = $1 AND friend_id = $2",
      [friend_id, user_id] 
    );
    
    const userRes = await pool.query('SELECT name FROM users WHERE id = $1', [user_id]);
    const accepterName = userRes.rows[0]?.name || 'Someone';

    io.to(friend_id).emit("new_notification", {
      id: `acc_${Date.now()}`,
      type: "friend_accepted",
      message: `${accepterName} accepted your friend request!`,
      created_at: new Date().toISOString(),
      is_read: false
    });

    res.json({ success: true, message: "Friend request accepted" });
  } catch (error) {
    console.error("Accept Friend Error:", error);
    res.status(500).json({ error: "Failed to accept request" });
  }
});

// 🚀 FRIENDS: DECLINE REQUEST 🚀
app.post('/api/friends/decline', async (req: Request, res: Response) => {
  const { user_id, friend_id } = req.body;
  try {
    await pool.query(
      "DELETE FROM friends WHERE user_id = $1 AND friend_id = $2",
      [friend_id, user_id] 
    );
    res.json({ success: true, message: "Friend request declined" });
  } catch (error) {
    console.error("Decline Friend Error:", error);
    res.status(500).json({ error: "Failed to decline request" });
  }
});

// 🚀 FRIENDS: CANCEL SENT REQUEST 🚀
app.post('/api/friends/cancel', async (req: Request, res: Response) => {
  const { user_id, friend_id } = req.body;
  try {
    await pool.query(
      'DELETE FROM friends WHERE user_id = $1 AND friend_id = $2 AND status = $3',
      [user_id, friend_id, 'pending']
    );
    res.json({ success: true, message: "Friend request cancelled" });
  } catch (error) {
    console.error("Cancel Friend Error:", error);
    res.status(500).json({ error: "Failed to cancel request" });
  }
});

// 🚀 FRIENDS: REMOVE EXISTING FRIEND 🚀
app.post('/api/friends/remove', async (req: Request, res: Response) => {
  const { user_id, friend_id } = req.body;
  try {
    await pool.query(
      'DELETE FROM friends WHERE (user_id = $1 AND friend_id = $2) OR (user_id = $2 AND friend_id = $1)',
      [user_id, friend_id]
    );
    res.json({ success: true, message: "Friend removed" });
  } catch (error) {
    console.error("Remove Friend Error:", error);
    res.status(500).json({ error: "Failed to remove friend" });
  }
});

// 🚀 GIFTS 🚀
app.post('/api/gifts', async (req: Request, res: Response) => {
  const { sender_id, receiver_id, gift_name } = req.body;
  try {
    await pool.query(
      'INSERT INTO gifts (sender_id, receiver_id, gift_name, created_at) VALUES ($1, $2, $3, NOW())',
      [sender_id, receiver_id, gift_name]
    );

    const userRes = await pool.query('SELECT name FROM users WHERE id = $1', [sender_id]);
    const senderName = userRes.rows[0]?.name || 'Someone';

    io.to(receiver_id).emit("new_notification", {
      id: `gift_${Date.now()}`,
      type: "gift",
      message: `${senderName} sent you a ${gift_name}!`,
      created_at: new Date().toISOString(),
      is_read: false
    });

    res.json({ success: true });
  } catch (error) {
    console.error("Gift Error:", error);
    res.status(500).json({ error: "Failed to send gift" });
  }
});

app.get('/api/gifts', async (req: Request, res: Response) => {
  try {
    const result = await pool.query(`
      SELECT g.*, u.name as sender_name, u.image as sender_image 
      FROM gifts g 
      LEFT JOIN users u ON g.sender_id = u.id 
      ORDER BY g.created_at DESC
    `);
    res.json(result.rows);
  } catch (error) {
    res.json([]);
  }
});

// ==========================================================
// 💬 LOBBY MESSAGES
// ==========================================================
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
    const userRes = await pool.query(
      'SELECT message_count, is_vip, role FROM users WHERE id = $1', 
      [sender_id]
    );
    
    if (userRes.rows.length > 0) {
        const user = userRes.rows[0];
        const isAdmin = user.role && user.role.toLowerCase() === 'admin';
        
        if (!user.is_vip && !isAdmin && (user.message_count || 0) >= 2) {
            return res.status(403).json({ error: "Limit Reached" }); 
        }
    }

    const result = await pool.query(
      'INSERT INTO lobby_messages (sender_id, content, created_at) VALUES ($1, $2, NOW()) RETURNING id',
      [sender_id, content]
    );

    await pool.query(
      'UPDATE users SET message_count = COALESCE(message_count, 0) + 1 WHERE id = $1', 
      [sender_id]
    );

    res.json({ 
      success: true, 
      id: result.rows[0].id.toString(), 
      time: new Date().toLocaleTimeString() 
    });

  } catch (error) {
    res.status(500).json({ error: "Failed to process lobby message" });
  }
});

// ==========================================================
// 🔒 PRIVATE MESSAGES
// ==========================================================
app.get('/api/messages', async (req: Request, res: Response) => {
  const myId = req.query.my_id as string;
  const otherId = req.query.other_id as string;
  
  // 🚀 ŠTIT 3: Sprečava da "test_user_id" sruši bazu
  if (!myId || myId === 'test_user_id' || myId === 'undefined') return res.json(otherId ? [] : {});

  try {
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
        FROM private_messages 
        WHERE sender_id = $1 OR receiver_id = $1
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
    res.json(otherId ? [] : {}); 
  }
});

app.post('/api/messages', async (req: Request, res: Response) => {
  const { sender_id, receiver_id, content } = req.body;
  try {
    
    const blockCheck = await pool.query(
      `SELECT id FROM blocks 
       WHERE (blocker_id = $1 AND blocked_id = $2) 
          OR (blocker_id = $2 AND blocked_id = $1)`,
      [sender_id, receiver_id]
    );

    if (blockCheck.rows.length > 0) {
        return res.status(403).json({ error: "Blocked" }); 
    }

    const userRes = await pool.query(
      'SELECT name, message_count, is_vip, role FROM users WHERE id = $1', 
      [sender_id]
    );
    
    let senderName = "Someone";

    if (userRes.rows.length > 0) {
        const user = userRes.rows[0];
        senderName = user.name;
        const isAdmin = user.role && user.role.toLowerCase() === 'admin';

        if (!user.is_vip && !isAdmin && (user.message_count || 0) >= 2) {
            return res.status(403).json({ error: "Limit Reached" }); 
        }
    }

    await pool.query(
      'INSERT INTO private_messages (sender_id, receiver_id, content, created_at) VALUES ($1, $2, $3, NOW())',
      [sender_id, receiver_id, content]
    );

    await pool.query(
      'UPDATE users SET message_count = COALESCE(message_count, 0) + 1 WHERE id = $1', 
      [sender_id]
    );

    io.to(receiver_id).emit("new_notification", {
      id: `msgnotif_${Date.now()}`,
      type: "new_message",
      message: `${senderName} sent you a private message!`,
      created_at: new Date().toISOString(),
      is_read: false
    });

    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: "Failed to process private message" });
  }
});

// 🚀 OVO JE JEDINA RUTINA KOJA JE PROMENJENA ZA TVOJU BAZU 🚀
app.post('/api/auth/signup', async (req: Request, res: Response) => {
  const { name, email, password, gender } = req.body;
  
  if (!name || !email || !password) {
    return res.status(400).json({ error: "All fields are required" });
  }

  try {
    const userCheck = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (userCheck.rows.length > 0) {
      return res.status(400).json({ error: "Email is already registered." });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Obrisana `password` kolona iz INSERT komande da bi radilo sa tvojom bazom
    const result = await pool.query(
      `INSERT INTO users (name, email, password_hash, gender, created_at) 
       VALUES ($1, $2, $3, $4, NOW()) RETURNING *`,
      [name, email, hashedPassword, gender]
    );

    res.json({ success: true, user: result.rows[0] });
  } catch (error) {
    console.error("Backend Signup Error:", error);
    res.status(500).json({ error: "Server failed to create account." });
  }
});

app.post('/api/settings/invisible', async (req: Request, res: Response) => {
  res.json({ success: true });
});

// ==========================================================
// 📡 SOCKET.IO REALTIME EVENT LISTENERS
// ==========================================================
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

// ==========================================================
// 🚀 START SERVER
// ==========================================================
const PORT = 3001; 
server.listen(PORT, '0.0.0.0', () => {
  console.log(`DateRoot TS Server running on http://0.0.0.0:${PORT}`);
});