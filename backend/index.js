import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import dotenv from 'dotenv';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import multer from 'multer';
import { Pool } from 'pg';
import axios from 'axios';

dotenv.config();
const app = express();
const port = process.env.PORT || 3000;
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/hackathon'
});

app.use(cors());
app.use(bodyParser.json());
const upload = multer({ dest: 'uploads/' });

// Health check endpoint
app.get('/api/health', async (req, res) => {
  try {
    // Test database connection
    const result = await pool.query('SELECT NOW()');
    res.json({ 
      status: 'OK', 
      database: 'Connected',
      timestamp: result.rows[0].now 
    });
  } catch (error) {
    res.status(500).json({ 
      status: 'ERROR', 
      database: 'Disconnected',
      error: error.message 
    });
  }
});

// JWT middleware
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.sendStatus(401);
  jwt.verify(token, process.env.JWT_SECRET || 'secret', (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
}

// Auth routes
app.post('/api/signup', async (req, res) => {
  const { email, password, name } = req.body;
  const hash = await bcrypt.hash(password, 10);
  try {
    const result = await pool.query('INSERT INTO users (email, password_hash, name) VALUES ($1, $2, $3) RETURNING id', [email, hash, name]);
    res.json({ id: result.rows[0].id });
  } catch (e) {
    res.status(400).json({ error: 'User already exists' });
  }
});

app.post('/api/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    
    // Check if required fields are provided
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }
    
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (result.rows.length === 0) return res.status(400).json({ error: 'Invalid credentials' });
    const user = result.rows[0];
    if (!(await bcrypt.compare(password, user.password_hash))) return res.status(400).json({ error: 'Invalid credentials' });
    const token = jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET || 'secret', { expiresIn: '1d' });
    res.json({ token, user: { id: user.id, email: user.email, name: user.name } });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Database connection failed. Please ensure PostgreSQL is running and database is set up.' });
  }
});

// Dashboard
app.get('/api/dashboard', authenticateToken, async (req, res) => {
  const userId = req.user.id;
  const user = await pool.query('SELECT id, email, name FROM users WHERE id = $1', [userId]);
  const records = await pool.query('SELECT * FROM records WHERE user_id = $1', [userId]);
  res.json({ user: user.rows[0], records: records.rows });
});

// File upload
app.post('/api/upload', authenticateToken, upload.single('file'), async (req, res) => {
  const userId = req.user.id;
  const file = req.file;
  const metadata = req.body.metadata ? JSON.parse(req.body.metadata) : {};
  await pool.query('INSERT INTO uploads (user_id, filename, filetype, metadata) VALUES ($1, $2, $3, $4)', [userId, file.filename, file.mimetype, metadata]);
  // Forward file to ML service
  const mlRes = await axios.post('http://localhost:8000/predict', {}, { params: { filename: file.filename } });
  res.json({ message: 'File uploaded', ml: mlRes.data });
});

// CRUD for records
app.get('/api/records', authenticateToken, async (req, res) => {
  const userId = req.user.id;
  const result = await pool.query('SELECT * FROM records WHERE user_id = $1', [userId]);
  res.json(result.rows);
});

app.post('/api/records', authenticateToken, async (req, res) => {
  const userId = req.user.id;
  const { title, data } = req.body;
  const result = await pool.query('INSERT INTO records (user_id, title, data) VALUES ($1, $2, $3) RETURNING *', [userId, title, data]);
  res.json(result.rows[0]);
});

app.put('/api/records/:id', authenticateToken, async (req, res) => {
  const userId = req.user.id;
  const { id } = req.params;
  const { title, data } = req.body;
  const result = await pool.query('UPDATE records SET title = $1, data = $2 WHERE id = $3 AND user_id = $4 RETURNING *', [title, data, id, userId]);
  res.json(result.rows[0]);
});

app.delete('/api/records/:id', authenticateToken, async (req, res) => {
  const userId = req.user.id;
  const { id } = req.params;
  await pool.query('DELETE FROM records WHERE id = $1 AND user_id = $2', [id, userId]);
  res.json({ success: true });
});

app.listen(port, () => {
  console.log(`Backend running on port ${port}`);
});
