import { NextResponse } from 'next/server';
import pool from '@/lib/db';

// 📩 GET: Load chat history between two users
export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const other_id = searchParams.get('other_id');

  try {
    // Get your real Admin ID
    const adminRes = await pool.query("SELECT id FROM users WHERE email = 'admin@test.com'");
    const my_id = adminRes.rows[0].id;

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
  } catch (error) {
    return NextResponse.json({ error: 'Failed to fetch messages' }, { status: 500 });
  }
}

// 📤 POST: Save a new message
export async function POST(req: Request) {
  try {
    const { receiver_id, content } = await req.json();
    
    const adminRes = await pool.query("SELECT id FROM users WHERE email = 'admin@test.com'");
    const sender_id = adminRes.rows[0].id;

    const result = await pool.query(
      'INSERT INTO private_messages (sender_id, receiver_id, content) VALUES ($1, $2, $3) RETURNING *',
      [sender_id, receiver_id, content]
    );

    return NextResponse.json(result.rows[0], { status: 201 });
  } catch (error) {
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