import { NextResponse } from 'next/server';
import pool from '@/lib/db';

// GET: Who viewed me
export async function GET() {
  try {
    const adminRes = await pool.query("SELECT id FROM users WHERE email = 'admin@test.com'");
    const my_id = adminRes.rows[0].id;

    const result = await pool.query(`
      SELECT u.* FROM users u
      JOIN profile_views v ON u.id = v.viewer_id
      WHERE v.viewed_id = $1
      ORDER BY v.created_at DESC
    `, [my_id]);

    return NextResponse.json(result.rows, { status: 200 });
  } catch (error) {
    return NextResponse.json({ error: 'Database Error' }, { status: 500 });
  }
}

// POST: Record a profile view
export async function POST(req: Request) {
  try {
    const { viewed_id } = await req.json();
    const adminRes = await pool.query("SELECT id FROM users WHERE email = 'admin@test.com'");
    const viewer_id = adminRes.rows[0].id;

    await pool.query(
      'INSERT INTO profile_views (viewer_id, viewed_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
      [viewer_id, viewed_id]
    );

    return NextResponse.json({ success: true }, { status: 201 });
  } catch (error) {
    return NextResponse.json({ error: 'Database Error' }, { status: 500 });
  }
}