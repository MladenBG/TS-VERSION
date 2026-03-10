import { NextResponse } from 'next/server';
import pool from '@/lib/db';

export async function POST(req: Request) {
  try {
    const { userId } = await req.json();

    if (!userId) {
      return NextResponse.json({ error: 'Missing user ID' }, { status: 400 });
    }

    // Delete the user from the database
    // Ensure your PostgreSQL tables (likes, messages, blocks, etc.) have ON DELETE CASCADE for the user_id
    await pool.query('DELETE FROM users WHERE id = $1', [userId]);

    return NextResponse.json({ success: true, message: 'Account successfully deleted.' }, { status: 200 });

  } catch (error) {
    console.error("Delete Account Error:", error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}