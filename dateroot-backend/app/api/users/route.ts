import { NextResponse } from 'next/server';
import pool from '@/lib/db';

export async function GET() {
  try {
    // 1. Fetch your Admin user so we have a REAL logged-in ID to test with
    const adminRes = await pool.query("SELECT id FROM users WHERE email = 'admin@test.com'");
    const adminId = adminRes.rows[0]?.id;

    // 2. Fetch all users EXCEPT you, and check if you liked them!
    const usersRes = await pool.query(`
      SELECT 
        u.*,
        EXISTS(SELECT 1 FROM likes l WHERE l.user_id = $1 AND l.liked_user_id = u.id) as "isFavorite"
      FROM users u
      WHERE u.id != $1
    `, [adminId]);

    return NextResponse.json(usersRes.rows, { status: 200 });
  } catch (error) {
    console.error("DB Error:", error);
    return NextResponse.json({ error: 'Internal Error' }, { status: 500 });
  }
}