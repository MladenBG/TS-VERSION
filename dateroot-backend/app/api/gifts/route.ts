import { NextResponse } from 'next/server';
import pool from '@/lib/db';

// 📩 GET: Fetch all gifts sent privately TO me
export async function GET() {
  try {
    const adminRes = await pool.query("SELECT id FROM users WHERE email = 'admin@test.com'");
    const my_id = adminRes.rows[0].id;

    const result = await pool.query(`
      SELECT g.id, g.gift_name, g.created_at, u.name as sender_name, u.image as sender_image
      FROM gifts g
      JOIN users u ON g.sender_id = u.id
      WHERE g.receiver_id = $1
      ORDER BY g.created_at DESC
    `, [my_id]);

    return NextResponse.json(result.rows, { status: 200 });
  } catch (error) {
    console.error("Gifts GET Error:", error);
    return NextResponse.json({ error: 'Database Error' }, { status: 500 });
  }
}

// 📤 POST: Send a gift
export async function POST(req: Request) {
  try {
    const { receiver_id, gift_name } = await req.json();
    
    const adminRes = await pool.query("SELECT id FROM users WHERE email = 'admin@test.com'");
    const sender_id = adminRes.rows[0].id;

    await pool.query(
      'INSERT INTO gifts (sender_id, receiver_id, gift_name) VALUES ($1, $2, $3)',
      [sender_id, receiver_id, gift_name]
    );

    return NextResponse.json({ success: true }, { status: 201 });
  } catch (error) {
    console.error("Gifts POST Error:", error);
    return NextResponse.json({ error: 'Database Error' }, { status: 500 });
  }
}