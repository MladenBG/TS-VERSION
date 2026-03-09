import { NextResponse } from 'next/server';
import pool from '@/lib/db';

// 📩 GET: Load chat history OR Inbox list
export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const my_id = searchParams.get('my_id'); // 🚀 GRABS REAL ID FROM APP
  const other_id = searchParams.get('other_id');

  if (!my_id) {
    return NextResponse.json({ error: 'Missing my_id' }, { status: 400 });
  }

  try {
    // 🚀 SCENARIO 1: Load a specific private chat between two people
    if (my_id && other_id) {
      const result = await pool.query(`
        SELECT * FROM private_messages 
        WHERE (sender_id = $1 AND receiver_id = $2) 
           OR (sender_id = $2 AND receiver_id = $1)
        ORDER BY created_at ASC
      `, [my_id, other_id]);

      // Map DB columns to your app's "sender: me/them" format
      const formatted = result.rows.map(m => ({
        id: m.id,
        text: m.content,
        sender: m.sender_id === my_id ? 'me' : 'them',
        created_at: m.created_at
      }));

      return NextResponse.json(formatted, { status: 200 });
    }

    // 🚀 SCENARIO 2: Load the entire Inbox (Latest message from all your conversations)
    // This is the missing piece that stops your inbox from being empty on refresh!
    const inbox = await pool.query(`
      SELECT DISTINCT ON (conversation_id) * FROM (
        SELECT *,
        CASE WHEN sender_id < receiver_id THEN sender_id || '_' || receiver_id
             ELSE receiver_id || '_' || sender_id END as conversation_id
        FROM private_messages
        WHERE sender_id = $1 OR receiver_id = $1
      ) t
      ORDER BY conversation_id, created_at DESC
    `, [my_id]);

    return NextResponse.json(inbox.rows, { status: 200 });

  } catch (error) {
    console.error("Messages GET Error:", error);
    return NextResponse.json({ error: 'Failed to fetch messages' }, { status: 500 });
  }
}

// 📤 POST: Save a new message
export async function POST(req: Request) {
  try {
    // 🚀 GRABS THE REAL SENDER FROM THE APP
    const { sender_id, receiver_id, content } = await req.json();

    if (!sender_id || !receiver_id || !content) {
      return NextResponse.json({ error: 'Missing data' }, { status: 400 });
    }

    const result = await pool.query(
      'INSERT INTO private_messages (sender_id, receiver_id, content) VALUES ($1, $2, $3) RETURNING *',
      [sender_id, receiver_id, content]
    );

    return NextResponse.json(result.rows[0], { status: 201 });
  } catch (error) {
    console.error("Messages POST Error:", error);
    return NextResponse.json({ error: 'Failed to send message' }, { status: 500 });
  }
}

// 🗑️ DELETE: Remove a message by ID
export async function DELETE(req: Request) {
  try {
    const { searchParams } = new URL(req.url);
    const id = searchParams.get('id');

    if (!id) {
      return NextResponse.json({ error: 'Message ID is required' }, { status: 400 });
    }

    const result = await pool.query(
      'DELETE FROM private_messages WHERE id = $1 RETURNING *',
      [id]
    );

    if (result.rowCount === 0) {
      return NextResponse.json({ error: 'Message not found' }, { status: 404 });
    }

    return NextResponse.json({ success: true, deleted: result.rows[0] }, { status: 200 });
  } catch (error) {
    console.error("Delete Error:", error);
    return NextResponse.json({ error: 'Failed to delete message' }, { status: 500 });
  }
}