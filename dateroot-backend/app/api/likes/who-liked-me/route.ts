import { NextResponse } from 'next/server';
import pool from '@/lib/db';

export async function GET() {
  try {
    const adminRes = await pool.query("SELECT id FROM users WHERE email = 'admin@test.com'");
    const my_id = adminRes.rows[0].id;

    const result = await pool.query(`
      SELECT u.* FROM users u
      JOIN likes l ON u.id = l.user_id
      WHERE l.liked_user_id = $1
      ORDER BY l.created_at DESC
    `, [my_id]);

    return NextResponse.json(result.rows, { status: 200 });
  } catch (error) {
    return NextResponse.json({ error: 'Database Error' }, { status: 500 });
  }
}