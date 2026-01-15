const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../../config/db');

const login = async (email, password) => {
  const [rows] = await pool.execute(
    'SELECT id, email, password_hash, name, role, dept FROM users WHERE email = ? LIMIT 1',
    [email]
  );
  if (!rows || rows.length === 0) return null;

  const user = rows[0];
  const isMatch = await bcrypt.compare(password, user.password_hash || '');
  if (!isMatch) return null;

  const token = jwt.sign(
    { sub: user.id, email: user.email, role: user.role, dept: user.dept },
    process.env.JWT_SECRET || 'secret',
    { expiresIn: '1d' }
  );

  return {
    token,
    user: {
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      dept: user.dept,
    },
  };
};

const getProfile = async (userId) => {
  const [rows] = await pool.execute(
    'SELECT id, email, name, role, dept FROM users WHERE id = ? LIMIT 1',
    [userId]
  );
  if (!rows || rows.length === 0) return null;
  const user = rows[0];
  return {
    id: user.id,
    email: user.email,
    name: user.name,
    role: user.role,
    dept: user.dept,
  };
};

module.exports = { login, getProfile };
