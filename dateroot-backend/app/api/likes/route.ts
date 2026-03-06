import { NextResponse } from 'next/server';
import pool from '@/lib/db';

export async function POST(req: Request) {
  try {
    const { liked_user_id } = await req.json();

    // Get your real Admin ID to satisfy PostgreSQL's strict security
    const adminRes = await pool.query("SELECT id FROM users WHERE email = 'admin@test.com'");
    const user_id = adminRes.rows[0].id;

    const existingLike = await pool.query(
      'SELECT id FROM likes WHERE user_id = $1 AND liked_user_id = $2',
      [user_id, liked_user_id]
    );

    if (existingLike.rows.length > 0) {
      await pool.query('DELETE FROM likes WHERE user_id = $1 AND liked_user_id = $2', [user_id, liked_user_id]);
      return NextResponse.json({ success: true, action: 'unliked' }, { status: 200 });
    } else {
      await pool.query('INSERT INTO likes (user_id, liked_user_id) VALUES ($1, $2)', [user_id, liked_user_id]);
      return NextResponse.json({ success: true, action: 'liked' }, { status: 201 });
    }

  } catch (error) {
    console.error('Like Database Error:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}