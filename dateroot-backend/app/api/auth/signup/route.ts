import { NextResponse } from 'next/server';

import pool from '@/lib/db';

import bcrypt from 'bcrypt';



export async function POST(req: Request) {

  try {

    const body = await req.json();

    const { email, password, name, gender } = body;



    if (!email || !password || !name) {

      return NextResponse.json({ error: 'Missing required fields' }, { status: 400 });

    }



    // 1. Check if user already exists

    const existingUser = await pool.query('SELECT id FROM users WHERE email = $1', [email]);

    if (existingUser.rows.length > 0) {

      return NextResponse.json({ error: 'Email already exists' }, { status: 400 });

    }



    // 2. Encrypt the password securely

    const saltRounds = 10;

    const passwordHash = await bcrypt.hash(password, saltRounds);



    // 3. Insert the new user into PostgreSQL

    const newUser = await pool.query(

      `INSERT INTO users (email, password_hash, name, gender)

       VALUES ($1, $2, $3, $4) RETURNING id, email, name, gender`,

      [email, passwordHash, name, gender]

    );



    return NextResponse.json({

      success: true,

      user: newUser.rows[0]

    }, { status: 201 });



  } catch (error) {

    console.error('Signup Error:', error);

    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });

  }

}

