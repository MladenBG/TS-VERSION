import { NextResponse } from 'next/server';
import pool from '@/lib/db';

// 📩 GET: Load Lobby History
export async function GET() {
  try {
    const result = await pool.query(`
      SELECT lm.id, lm.content as text, u.name as user, TO_CHAR(lm.created_at, 'HH24:MI') as time 
      FROM lobby_messages lm
      JOIN users u ON lm.sender_id = u.id
      ORDER BY lm.created_at ASC 
      LIMIT 100
    `);
    
    return NextResponse.json(result.rows, { status: 200 });
  } catch (error) {
    console.error("Lobby GET Error:", error);
    return NextResponse.json({ error: 'Failed to fetch lobby history' }, { status: 500 });
  }
}

// 📤 POST: Save a new Lobby Message
export async function POST(req: Request) {
  try {
    // 🚀 Now expects sender_id just like private chats!
    const { sender_id, content } = await req.json();

    if (!sender_id || !content) {
      return NextResponse.json({ error: 'Missing data' }, { status: 400 });
    }

    const result = await pool.query(
      `INSERT INTO lobby_messages (sender_id, content) 
       VALUES ($1, $2) 
       RETURNING id, TO_CHAR(created_at, 'HH24:MI') as time`,
      [sender_id, content]
    );

    return NextResponse.json(result.rows[0], { status: 201 });
  } catch (error) {
    console.error("Lobby POST Error:", error);
    return NextResponse.json({ error: 'Failed to save lobby message' }, { status: 500 });
  }
}