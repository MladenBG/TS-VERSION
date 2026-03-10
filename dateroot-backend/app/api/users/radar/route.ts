import { NextResponse } from 'next/server';
import pool from '@/lib/db';

export async function POST(req: Request) {
  try {
    const { userId, latitude, longitude } = await req.json();

    if (!latitude || !longitude) {
      return NextResponse.json({ error: 'Missing GPS coordinates' }, { status: 400 });
    }

    // 1. Update the user's current location in DB
    await pool.query(
      'UPDATE users SET latitude = $1, longitude = $2 WHERE id = $3',
      [latitude, longitude, userId]
    );

    // 2. Fetch users within 100km using the Haversine formula
    const radarQuery = `
      SELECT 
        id, 
        name, 
        image, 
        age,
        ( 6371 * acos( cos( radians($1) ) * cos( radians( latitude ) ) * cos( radians( longitude ) - radians($2) ) + sin( radians($1) ) * sin( radians( latitude ) ) ) ) AS distance_km
      FROM users
      WHERE id != $3 
        AND latitude IS NOT NULL 
        AND longitude IS NOT NULL
        AND is_banned = FALSE
      HAVING ( 6371 * acos( cos( radians($1) ) * cos( radians( latitude ) ) * cos( radians( longitude ) - radians($2) ) + sin( radians($1) ) * sin( radians( latitude ) ) ) ) < 100 
      ORDER BY distance_km ASC
      LIMIT 15;
    `;

    const result = await pool.query(radarQuery, [latitude, longitude, userId]);

    return NextResponse.json(result.rows, { status: 200 });

  } catch (error) {
    console.error("Radar Distance Error:", error);
    return NextResponse.json({ error: 'Failed to calculate radar distances' }, { status: 500 });
  }
}