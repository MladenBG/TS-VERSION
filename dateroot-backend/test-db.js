require('dotenv').config();
const { Client } = require('pg');

const client = new Client({
  connectionString: process.env.DATABASE_URL,
});

async function testConnection() {
  try {
    await client.connect();
    console.log("✅ SUCCESS! Connected to PostgreSQL.");
    
    const res = await client.query('SELECT NOW()');
    console.log("Database Time:", res.rows[0].now);
    
  } catch (err) {
    console.error("❌ FAILED to connect:", err.message);
  } finally {
    await client.end();
  }
}

testConnection();