import { NextResponse } from 'next/server';
import pool from '@/lib/db';

export async function POST(req: Request) {
  try {
    const { action, target_id } = await req.json();

    // 🔴 1. WIPE ENTIRE LOBBY (Fixed: Uses DELETE instead of TRUNCATE to avoid DB errors)
    if (action === 'wipe_lobby') {
      await pool.query('DELETE FROM lobby_messages');
      return NextResponse.json({ success: true, message: 'Lobby completely wiped.' });
    }

    // 🔴 2. WIPE ALL PRIVATE CHATS (Fixed)
    if (action === 'wipe_private') {
      await pool.query('DELETE FROM private_messages');
      return NextResponse.json({ success: true, message: 'All private chats wiped.' });
    }

    // 🔴 3. BAN USER
    if (action === 'ban_user') {
      if (!target_id) return NextResponse.json({ error: 'Missing user ID' }, { status: 400 });
      await pool.query('UPDATE users SET is_banned = TRUE WHERE id = $1', [target_id]);
      return NextResponse.json({ success: true, message: 'User banned.' });
    }

    // 🟢 4. UNBAN USER
    if (action === 'unban_user') {
      if (!target_id) return NextResponse.json({ error: 'Missing user ID' }, { status: 400 });
      await pool.query('UPDATE users SET is_banned = FALSE WHERE id = $1', [target_id]);
      return NextResponse.json({ success: true, message: 'User unbanned.' });
    }

    // 🔴 5. IP BLOCK USER
    if (action === 'block_ip') {
      if (!target_id) return NextResponse.json({ error: 'Missing user ID' }, { status: 400 });
      
      const user = await pool.query('SELECT last_ip FROM users WHERE id = $1', [target_id]);
      const ip = user.rows[0]?.last_ip;

      await pool.query('UPDATE users SET is_banned = TRUE WHERE id = $1', [target_id]);

      if (ip) {
        await pool.query('INSERT INTO banned_ips (ip) VALUES ($1) ON CONFLICT DO NOTHING', [ip]);
        return NextResponse.json({ success: true, message: 'User banned and IP strictly blocked.' });
      } else {
        return NextResponse.json({ success: true, message: 'User banned (No IP found to block).' });
      }
    }

    // 🟢 6. UNBLOCK IP (AND UNBAN USER)
    if (action === 'unblock_ip') {
      if (!target_id) return NextResponse.json({ error: 'Missing user ID' }, { status: 400 });
      
      const user = await pool.query('SELECT last_ip FROM users WHERE id = $1', [target_id]);
      const ip = user.rows[0]?.last_ip;

      await pool.query('UPDATE users SET is_banned = FALSE WHERE id = $1', [target_id]);

      if (ip) {
        await pool.query('DELETE FROM banned_ips WHERE ip = $1', [ip]);
        return NextResponse.json({ success: true, message: 'User unbanned and IP unblocked.' });
      } else {
        return NextResponse.json({ success: true, message: 'User unbanned (No IP found to unblock).' });
      }
    }

    // 🚀 7. PERMANENTLY DELETE USER 🚀
    if (action === 'delete_user') {
      if (!target_id) return NextResponse.json({ error: 'Missing user ID' }, { status: 400 });
      
      // Deletes the user permanently. 
      // (Make sure your foreign keys in the DB are set to ON DELETE CASCADE)
      await pool.query('DELETE FROM users WHERE id = $1', [target_id]);
      
      return NextResponse.json({ success: true, message: 'User permanently deleted.' });
    }

    return NextResponse.json({ error: 'Invalid admin action' }, { status: 400 });

  } catch (error) {
    console.error("Admin Action Error:", error);
    return NextResponse.json({ error: 'Failed to execute admin command' }, { status: 500 });
  }
}