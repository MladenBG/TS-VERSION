// File: dateroot-backend/server.js
const express = require("express");
const http = require("http");
const { Server } = require("socket.io");
const cors = require("cors");
const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');
const { Pool } = require('pg'); 

const app = express();
const server = http.createServer(app);

// Enable CORS for API requests
app.use(cors());
app.use(express.json());

// ==========================================
// 🚀 POSTGRESQL DATABASE CONNECTION 🚀
// ==========================================
const pool = new Pool({
  // 🚨 REPLACE "YOUR_DB_PASSWORD" WITH YOUR ACTUAL POSTGRES PASSWORD! 🚨
  connectionString: 'postgresql://postgres:YOUR_DB_PASSWORD@localhost:5432/dateroot'
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

// The endpoint your Expo app will call to get an upload ticket
app.get('/api/get-upload-url', async (req, res) => {
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

// ==========================================
// 🚀 TRUST & SAFETY API (REPORT / BLOCK) 🚀
// ==========================================

// 1. Block a user
app.post('/api/block', async (req, res) => {
  const { blockerId, blockedId } = req.body;
  try {
    await pool.query(
      'INSERT INTO blocks (blocker_id, blocked_id) VALUES ($1, $2)',
      [blockerId, blockedId]
    );
    res.json({ success: true, message: "User blocked successfully" });
  } catch (error) {
    console.error("Block Error:", error);
    res.status(500).json({ error: "Failed to block user" });
  }
});

// 2. Report a user
app.post('/api/report', async (req, res) => {
  const { reporterId, reportedId, reason } = req.body;
  try {
    await pool.query(
      'INSERT INTO reports (reporter_id, reported_id, reason) VALUES ($1, $2, $3)',
      [reporterId, reportedId, reason]
    );
    res.json({ success: true, message: "Report sent to admin dashboard" });
  } catch (error) {
    console.error("Report Error:", error);
    res.status(500).json({ error: "Failed to report user" });
  }
});

// 3. Get pending reports for Admin Dashboard
app.get('/api/admin/reports', async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM reports WHERE status = 'pending' ORDER BY id DESC");
    res.json(result.rows);
  } catch (error) {
    console.error("Admin Fetch Reports Error:", error);
    res.status(500).json({ error: "Failed to fetch reports" });
  }
});

// 4. Resolve/Dismiss a report
app.post('/api/admin/resolve-report', async (req, res) => {
  const { reportId } = req.body;
  try {
    await pool.query("UPDATE reports SET status = 'resolved' WHERE id = $1", [reportId]);
    res.json({ success: true });
  } catch (error) {
    console.error("Resolve Report Error:", error);
    res.status(500).json({ error: "Failed to resolve report" });
  }
});

// 5. Get blocked list for a user
app.get('/api/blocks/:userId', async (req, res) => {
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
    console.error("Fetch Blocks Error:", error);
    res.status(500).json({ error: "Failed to fetch blocked users" });
  }
});

// 6. Unblock a user
app.post('/api/unblock', async (req, res) => {
  const { blockerId, blockedId } = req.body;
  try {
    await pool.query(
      'DELETE FROM blocks WHERE blocker_id = $1 AND blocked_id = $2',
      [blockerId, blockedId]
    );
    res.json({ success: true, message: "User unblocked successfully" });
  } catch (error) {
    console.error("Unblock Error:", error);
    res.status(500).json({ error: "Failed to unblock user" });
  }
});

// ==========================================
// 🚀 WEBRTC SIGNALING LOGIC 🚀
// ==========================================
io.on("connection", (socket) => {
  console.log("A user connected:", socket.id);

  socket.on("send_lobby_msg", (data) => {
    socket.broadcast.emit("receive_lobby_msg", data);
  });

  socket.on("register_user", (userId) => {
    socket.join(userId);
    console.log(`User ${userId} registered for private signaling.`);
  });

  socket.on("start_call", (data) => {
    console.log(`${data.callerName} is calling ${data.receiverId}`);
    socket.to(data.receiverId).emit("incoming_call", {
      callerId: data.callerId,
      callerName: data.callerName,
      cloudflareSessionId: data.cloudflareSessionId
    });
  });

  socket.on("decline_call", (data) => {
    socket.to(data.callerId).emit("call_declined");
  });

  socket.on("disconnect", () => {
    console.log("User disconnected:", socket.id);
  });
});

// 🚀 RUNNING ON PORT 3001
const PORT = 3001; 
server.listen(PORT, () => {
  console.log(`DateRoot Socket/Signaling Server running on port ${PORT}`);
});