import { NextResponse } from 'next/server';
import pool from '@/lib/db';
import bcrypt from 'bcrypt';

export async function GET() {
  try {
    // 1. DELETE EVERYONE EXCEPT YOUR ADMIN ACCOUNT
    // This instantly wipes out all those old profiles and bad pictures
    await pool.query("DELETE FROM users WHERE email != 'admin@test.com'");

    // 2. CREATE A UNIVERSAL PASSWORD FOR ALL TEST ACCOUNTS
    const passwordHash = await bcrypt.hash('password123', 10);

    // 3. INTERNATIONAL DATA POOLS
    const cities = ['New York, USA', 'London, UK', 'Tokyo, Japan', 'Paris, France', 'Berlin, Germany', 'Sydney, Australia', 'Dubai, UAE', 'Toronto, Canada', 'Rome, Italy', 'Madrid, Spain', 'Seoul, South Korea', 'Rio de Janeiro, Brazil', 'Mexico City, Mexico', 'Amsterdam, Netherlands', 'Vienna, Austria'];
    const firstNamesMale = ['James', 'Mateo', 'Robert', 'Michael', 'Luca', 'David', 'Richard', 'Joseph', 'Thomas', 'Carlos', 'Alejandro', 'Ivan', 'Lucas', 'Oliver', 'Noah'];
    const firstNamesFemale = ['Emma', 'Patricia', 'Jennifer', 'Sofia', 'Elizabeth', 'Barbara', 'Susan', 'Jessica', 'Sarah', 'Maria', 'Camila', 'Valeria', 'Isabella', 'Mia', 'Ava'];
    const lastNames = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson'];
    const sexualities = ['Straight', 'Gay', 'Bisexual'];

    // 4. GENERATE 90 NEW USERS (STRICTLY ADULTS ONLY)
    for (let i = 1; i <= 90; i++) {
      const isMale = i % 2 === 0;
      const firstName = isMale ? firstNamesMale[i % firstNamesMale.length] : firstNamesFemale[i % firstNamesFemale.length];
      const lastName = lastNames[i % lastNames.length];
      
      const name = `${firstName} ${lastName}`;
      const email = `user${i}@test.com`;
      const gender = isMale ? 'Male' : 'Female';
      const sexuality = sexualities[i % 3];
      const city = cities[i % cities.length];
      
      // 🚀 GUARANTEED ADULT AGES (20 to 45 years old)
      const age = 20 + (i % 26); 
      
      // 🚀 FIXED: STRICTLY VERIFIED ADULT STOCK PHOTOS ONLY
      const image = isMale 
        ? `https://randomuser.me/api/portraits/men/${i % 90}.jpg`
        : `https://randomuser.me/api/portraits/women/${i % 90}.jpg`;
      
      const bio = `Hi! I'm ${firstName} from ${city}. I love traveling, trying new food, and meeting new people from all over the world!`;

      await pool.query(
        `INSERT INTO users (email, password_hash, name, gender, age, city, image, sexuality, bio, is_vip, role) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)`,
        [email, passwordHash, name, gender, age, city, image, sexuality, bio, false, 'user']
      );
    }

    return NextResponse.json({ 
      success: true, 
      message: 'Success! Your Admin account is safe, old users are gone, and 90 brand new ADULT (20+) International users were created.' 
    });

  } catch (error) {
    console.error('Seeding Error:', error);
    return NextResponse.json({ error: 'Failed to seed database' }, { status: 500 });
  }
}