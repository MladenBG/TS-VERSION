// File: dateroot-backend/server.ts
import express from "express";
import { Request, Response } from "express";
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

// Enable CORS for API requests
app.use(cors());
app.use(express.json());

// ==========================================
// 🚀 TRACKER: SEE ALL APP REQUESTS IN TERMINAL
// ==========================================
app.use((req, res, next) => {
  console.log(`➡️  [${req.method}] request received at: ${req.url}`);
  next();
});

// ==========================================
// 🚀 POSTGRESQL DATABASE CONNECTION 🚀
// ==========================================
const pool = new Pool({
  // 🚨 REPLACE "YOUR_DB_PASSWORD" WITH YOUR ACTUAL POSTGRES PASSWORD! 🚨
  connectionString: process.env.DATABASE_URL || 'postgresql://postgres:YOUR_DB_PASSWORD@127.0.0.1:5432/dateroot',
  connectionTimeoutMillis: 5000, // 🚀 THIS KILLS THE INFINITE SPIN IF DB FAILS
});

// Test the connection immediately so we know if it's broken
pool.connect((err, client, release) => {
  if (err) {
    console.error('❌ DATABASE CONNECTION FAILED. Is PostgreSQL running?', err.message);
  } else {
    console.log('✅ DATABASE CONNECTED SUCCESSFULLY');
    release();
  }
});

// Enable CORS for Socket.io
const io = new Server(server, {
  cors: {
    origin: "*", 
    methods: ["GET", "POST"]
  }
});

// ==========================================
// 🚀 CLOUDFLARE R2 CONFIGURATION 🚀
// ==========================================
const s3 = new S3Client({
  region: 'auto',
  endpoint: `https://9751fff4aee9e644766dfa510fedd00f.r2.cloudflarestorage.com`,
  credentials: {
    accessKeyId: 'c1ba1c54e0b5b6595eba808f6fdc23e1',
    secretAccessKey: 'e3332852e869d466f7bb50152adc1b2ddd148b14cf682e0e5544986fc5ddeb16',
  },
});

// ==========================================
// 🚀 INTERFACES 🚀
// ==========================================
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

// ==========================================
// 🚀 ROUTES 🚀
// ==========================================

// ==========================================
// 🚀 AUTHENTICATION ROUTES (LOGIN/REGISTER)
// ==========================================
app.post('/api/login', async (req: Request, res: Response) => {
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
    
    // Check password
    const isValid = await bcrypt.compare(password, user.password); 

    if (!isValid) {
      return res.status(401).json({ error: "Wrong password" });
    }

    res.json({ success: true, user: user });
  } catch (error) {
    console.error("Login Error:", error);
    res.status(500).json({ error: "Server crashed during login" });
  }
});


// 🚀 GENERATE CLOUDFLARE UPLOAD TICKET 
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

// 🚀 1. FETCH ALL USERS (Includes Gallery and Joined Date)
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

// 🚀 2. SAVE NEW PROFILE PICTURE + CAPTURE IP 
app.post('/api/users/update-image', async (req: Request, res: Response) => {
  const { userId, imageUrl } = req.body as UserUpdatePayload;
  const userIp = req.headers['x-forwarded-for'] || req.socket.remoteAddress;
  
  if (!userId || !imageUrl) {
    return res.status(400).json({ error: "Missing userId or imageUrl" });
  }

  try {
    // Updates image AND last_ip at the same time for security
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

// 🚀 3. ADD IMAGE TO PERMANENT GALLERY 
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

// 🚀 4. REMOVE IMAGE FROM PERMANENT GALLERY 
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

// ==========================================
// 🚀 TRUST & SAFETY API 
// ==========================================

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

// 🚀 ADMIN VIEW: PULL IP LOGS 🛰️
app.get('/api/admin/ip-logs', async (req: Request, res: Response) => {
    try {
      const result = await pool.query('SELECT name, email, last_ip, created_at FROM users WHERE last_ip IS NOT NULL');
      res.json(result.rows);
    } catch (error) {
      res.status(500).json({ error: "Could not fetch IP logs" });
    }
});

// ==========================================
// 🚀 WEBRTC SIGNALING & CHAT 🚀
// ==========================================
io.on("connection", (socket: Socket) => {
  console.log("🔌 A user connected:", socket.id);

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
    console.log("❌ User disconnected:", socket.id);
  });
});

const PORT = 3001; 
// 🚀 THIS IS THE FIX: '0.0.0.0' ALLOWS THE EMULATOR TO CONNECT
server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 DateRoot TS Server running on http://0.0.0.0:${PORT}`);
});