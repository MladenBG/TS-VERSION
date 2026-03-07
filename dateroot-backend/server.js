// File: dateroot-backend/server.js
const express = require("express");
const http = require("http");
const { Server } = require("socket.io");
const cors = require("cors");
const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');

const app = express();
const server = http.createServer(app);

// Enable CORS for API requests
app.use(cors());
app.use(express.json());

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
  // FIXED: Added the full https URL around your Account ID
  endpoint: `https://9751fff4aee9e644766dfa510fedd00f.r2.cloudflarestorage.com`,
  credentials: {
    accessKeyId: 'c1ba1c54e0b5b6595eba808f6fdc23e1',
    secretAccessKey: 'e3332852e869d466f7bb50152adc1b2ddd148b14cf682e0e5544986fc5ddeb16',
  },
});

// The endpoint your Expo app will call to get an upload ticket
app.get('/api/get-upload-url', async (req, res) => {
  try {
    // Generate a highly unique filename so users don't overwrite each other
    const fileName = `profile_${Date.now()}_${Math.floor(Math.random() * 10000)}.webp`;

    const command = new PutObjectCommand({
      // FIXED: Changed to your actual bucket name!
      Bucket: 'imagespic', 
      Key: fileName,
      ContentType: 'image/webp',
    });

    // Generate a secure ticket that expires in 60 seconds
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
// 🚀 WEBRTC SIGNALING LOGIC 🚀
// ==========================================
io.on("connection", (socket) => {
  console.log("A user connected:", socket.id);

  // 1. Lobby Chat Routing
  socket.on("send_lobby_msg", (data) => {
    socket.broadcast.emit("receive_lobby_msg", data);
  });

  // 2. Register the user's phone to a private room
  socket.on("register_user", (userId) => {
    socket.join(userId);
    console.log(`User ${userId} registered for private signaling.`);
  });

  // 3. User A routes a WebRTC Call Request to User B
  socket.on("start_call", (data) => {
    console.log(`${data.callerName} is calling ${data.receiverId}`);
    socket.to(data.receiverId).emit("incoming_call", {
      callerId: data.callerId,
      callerName: data.callerName,
      cloudflareSessionId: data.cloudflareSessionId
    });
  });

  // 4. User B rejects the call
  socket.on("decline_call", (data) => {
    socket.to(data.callerId).emit("call_declined");
  });

  socket.on("disconnect", () => {
    console.log("User disconnected:", socket.id);
  });
});

// 🚀 RUNNING ON PORT 3001 TO AVOID NEXT.JS 🚀
const PORT = 3001; 
server.listen(PORT, () => {
  console.log(`DateRoot Socket/Signaling Server running on port ${PORT}`);
});