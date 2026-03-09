import { NextResponse } from 'next/server';
import pool from '@/lib/db';

// ✅ POST: Admin dismisses or resolves a report
export async function POST(req: Request) {
  try {
    const { reportId } = await req.json();

    if (!reportId) {
      return NextResponse.json({ error: 'Missing report ID' }, { status: 400 });
    }

    // Delete the report from the table so it disappears from the dashboard
    await pool.query(`DELETE FROM reports WHERE id = $1`, [reportId]);

    return NextResponse.json({ success: true }, { status: 200 });
  } catch (error) {
    console.error("Resolve Report Error:", error);
    return NextResponse.json({ error: 'Failed to resolve report' }, { status: 500 });
  }
}