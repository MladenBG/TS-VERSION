import { NextResponse } from 'next/server';
import pool from '@/lib/db';
import bcrypt from 'bcrypt';

export async function POST(req: Request) {
  try {
    const body = await req.json();
    const { email, password } = body;

    if (!email || !password) {
      return NextResponse.json({ error: 'Missing email or password' }, { status: 400 });
    }

    // 1. Find the user in the database
    const userResult = await pool.query('SELECT * FROM users WHERE email = $1', [email.toLowerCase()]);
    const user = userResult.rows[0];

    if (!user) {
      return NextResponse.json({ error: 'Invalid email or password' }, { status: 401 });
    }

    // 2. Compare the typed password with the encrypted hash in the database
    const passwordsMatch = await bcrypt.compare(password, user.password_hash);
    
    if (!passwordsMatch) {
      return NextResponse.json({ error: 'Invalid email or password' }, { status: 401 });
    }

    // 3. Login successful!
    return NextResponse.json({ 
      success: true, 
      user: { 
        id: user.id, 
        email: user.email, 
        name: user.name, 
        is_vip: user.is_vip 
      } 
    }, { status: 200 });

  } catch (error) {
    console.error('Login Error:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}