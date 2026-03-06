import { NextResponse } from 'next/server';
import pool from '@/lib/db';

export async function POST(req: Request) {
  try {
    const { friend_id } = await req.json();

    // Securely fetching your real Admin ID for testing
    const adminRes = await pool.query("SELECT id FROM users WHERE email = 'admin@test.com'");
    const user_id = adminRes.rows[0].id;

    // ON CONFLICT DO NOTHING stops the database from crashing if they click "Add Friend" twice
    await pool.query(
      'INSERT INTO friends (user_id, friend_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
      [user_id, friend_id]
    );

    return NextResponse.json({ success: true, message: 'Friend request sent!' }, { status: 201 });
  } catch (error) {
    console.error('Friends Database Error:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}