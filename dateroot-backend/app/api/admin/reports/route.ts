import { NextResponse } from 'next/server';
import pool from '@/lib/db';

// 📩 GET: Load all pending reports for the Admin Dashboard
export async function GET() {
  try {
    const result = await pool.query('SELECT * FROM reports ORDER BY created_at DESC');
    return NextResponse.json(result.rows, { status: 200 });
  } catch (error) {
    console.error("Fetch Reports Error:", error);
    return NextResponse.json({ error: 'Failed to fetch reports' }, { status: 500 });
  }
}

// 🚨 POST: User submits a new report from the Private Chat
export async function POST(req: Request) {
  try {
    // We get the IDs and the reason from the frontend
    const { reporter_id, reported_id, reason } = await req.json();

    if (!reporter_id || !reported_id) {
      return NextResponse.json({ error: 'Missing IDs' }, { status: 400 });
    }

    // Insert into the reports table
    await pool.query(
      `INSERT INTO reports (reporter_id, reported_id, reason) VALUES ($1, $2, $3)`,
      [reporter_id, reported_id, reason || 'Inappropriate behavior']
    );

    return NextResponse.json({ success: true }, { status: 201 });
  } catch (error) {
    console.error("Submit Report Error:", error);
    return NextResponse.json({ error: 'Failed to submit report' }, { status: 500 });
  }
}