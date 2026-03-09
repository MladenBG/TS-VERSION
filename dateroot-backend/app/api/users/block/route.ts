import { NextResponse } from 'next/server';
import pool from '@/lib/db';

// 🛑 POST: Block a user
export async function POST(req: Request) {
  try {
    const { blocker_id, blocked_id } = await req.json();

    if (!blocker_id || !blocked_id) {
      return NextResponse.json({ error: 'Missing IDs' }, { status: 400 });
    }

    // Insert into the blocks table we saw in your schema
    await pool.query(
      `INSERT INTO blocks (blocker_id, blocked_id) VALUES ($1, $2) ON CONFLICT DO NOTHING`,
      [blocker_id, blocked_id]
    );

    return NextResponse.json({ success: true, message: 'User blocked successfully' }, { status: 201 });
  } catch (error) {
    console.error("Block Error:", error);
    return NextResponse.json({ error: 'Failed to block user' }, { status: 500 });
  }
}