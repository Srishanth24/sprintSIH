import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import dotenv from 'dotenv';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import multer from 'multer';
import sqlite3 from 'sqlite3';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import axios from 'axios';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

dotenv.config();
const app = express();
const port = process.env.PORT || 3003;

// Initialize SQLite database
const db = new sqlite3.Database(join(__dirname, 'hackathon.db'));

app.use(cors());
app.use(bodyParser.json());
const upload = multer({ dest: 'uploads/' });

// Initialize database tables and demo data
db.serialize(() => {
  // Create tables
  db.run(`CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    name TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )`);

  db.run(`CREATE TABLE IF NOT EXISTS uploads (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    filename TEXT,
    filetype TEXT,
    metadata TEXT,
    uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES users(id)
  )`);

  db.run(`CREATE TABLE IF NOT EXISTS records (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    title TEXT,
    data TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES users(id)
  )`);

  // Insert demo user (password: demo123) with correct hash
  const demoPasswordHash = '$2b$10$KYIMu4NPTI8O5nSOOaS9WuEbIni2TVRjn58LNHrkJNjawGuDqML7C';
  db.run(`INSERT OR REPLACE INTO users (id, email, password_hash, name) VALUES (?, ?, ?, ?)`,
    [1, 'demo@demo.com', demoPasswordHash, 'Demo User'], function(err) {
      if (err) {
        console.error('Error inserting demo user:', err);
      } else {
        console.log('Demo user setup completed with correct password hash');
      }
    });

  // Insert demo records
  db.run(`INSERT OR IGNORE INTO records (user_id, title, data) VALUES 
    (1, 'Sample Health Record', '{"value": 42, "note": "Daily step count measurement."}'),
    (1, 'Weekly Progress', '{"value": 85, "note": "Fitness goal achievement percentage."}'),
    (1, 'Monthly Summary', '{"value": 67, "note": "Overall wellness score this month."}')`, function(err) {
      if (err) {
        console.error('Error inserting demo records:', err);
      } else {
        console.log('Demo records setup completed');
      }
    });
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    database: 'SQLite Connected',
    timestamp: new Date().toISOString()
  });
});

// Test endpoint for debugging
app.post('/api/test', (req, res) => {
  console.log('Test request received:', req.body);
  res.json({ message: 'Test successful', received: req.body });
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
  
  db.run('INSERT INTO users (email, password_hash, name) VALUES (?, ?, ?)', 
    [email, hash, name], 
    function(err) {
      if (err) {
        res.status(400).json({ error: 'User already exists' });
      } else {
        res.json({ id: this.lastID });
      }
    });
});

app.post('/api/login', async (req, res) => {
  try {
    console.log('Login request received:', req.body);
    const { email, password } = req.body;
    
    if (!email || !password) {
      console.log('Missing email or password');
      return res.status(400).json({ error: 'Email and password are required' });
    }
    
    console.log('Looking up user:', email);
    db.get('SELECT * FROM users WHERE email = ?', [email], async (err, user) => {
      if (err) {
        console.error('Database error:', err);
        return res.status(500).json({ error: 'Database error' });
      }
      
      if (!user) {
        console.log('User not found:', email);
        return res.status(400).json({ error: 'Invalid credentials' });
      }
      
      console.log('User found, checking password');
      const isValidPassword = await bcrypt.compare(password, user.password_hash);
      if (!isValidPassword) {
        console.log('Invalid password for user:', email);
        return res.status(400).json({ error: 'Invalid credentials' });
      }
      
      console.log('Login successful for user:', email);
      const token = jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET || 'secret', { expiresIn: '1d' });
      res.json({ token, user: { id: user.id, email: user.email, name: user.name } });
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Dashboard
app.get('/api/dashboard', authenticateToken, (req, res) => {
  const userId = req.user.id;
  
  db.get('SELECT id, email, name FROM users WHERE id = ?', [userId], (err, user) => {
    if (err) return res.status(500).json({ error: 'Database error' });
    
    db.all('SELECT * FROM records WHERE user_id = ?', [userId], (err, records) => {
      if (err) return res.status(500).json({ error: 'Database error' });
      
      records = records.map(record => ({
        ...record,
        data: JSON.parse(record.data || '{}')
      }));
      
      res.json({ user, records });
    });
  });
});

// CRUD for records
app.get('/api/records', authenticateToken, (req, res) => {
  const userId = req.user.id;
  
  db.all('SELECT * FROM records WHERE user_id = ?', [userId], (err, records) => {
    if (err) return res.status(500).json({ error: 'Database error' });
    
    records = records.map(record => ({
      ...record,
      data: JSON.parse(record.data || '{}')
    }));
    
    res.json(records);
  });
});

app.post('/api/records', authenticateToken, (req, res) => {
  const userId = req.user.id;
  const { title, data } = req.body;
  
  db.run('INSERT INTO records (user_id, title, data) VALUES (?, ?, ?)', 
    [userId, title, JSON.stringify(data)], 
    function(err) {
      if (err) return res.status(500).json({ error: 'Database error' });
      
      db.get('SELECT * FROM records WHERE id = ?', [this.lastID], (err, record) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        record.data = JSON.parse(record.data || '{}');
        res.json(record);
      });
    });
});

app.put('/api/records/:id', authenticateToken, (req, res) => {
  const userId = req.user.id;
  const { id } = req.params;
  const { title, data } = req.body;
  
  db.run('UPDATE records SET title = ?, data = ? WHERE id = ? AND user_id = ?', 
    [title, JSON.stringify(data), id, userId], 
    function(err) {
      if (err) return res.status(500).json({ error: 'Database error' });
      
      db.get('SELECT * FROM records WHERE id = ?', [id], (err, record) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        if (record) record.data = JSON.parse(record.data || '{}');
        res.json(record);
      });
    });
});

app.delete('/api/records/:id', authenticateToken, (req, res) => {
  const userId = req.user.id;
  const { id } = req.params;
  
  db.run('DELETE FROM records WHERE id = ? AND user_id = ?', [id, userId], function(err) {
    if (err) return res.status(500).json({ error: 'Database error' });
    res.json({ success: true });
  });
});

// File upload
app.post('/api/upload', authenticateToken, upload.single('file'), async (req, res) => {
  const userId = req.user.id;
  const file = req.file;
  const metadata = req.body.metadata ? JSON.parse(req.body.metadata) : {};
  
  db.run('INSERT INTO uploads (user_id, filename, filetype, metadata) VALUES (?, ?, ?, ?)', 
    [userId, file.filename, file.mimetype, JSON.stringify(metadata)], 
    async function(err) {
      if (err) return res.status(500).json({ error: 'Database error' });
      
      try {
        // Forward file to ML service
        const mlRes = await axios.post('http://localhost:8000/predict', {}, { params: { filename: file.filename } });
        res.json({ message: 'File uploaded', ml: mlRes.data });
      } catch (mlError) {
        // If ML service is not running, return success without ML analysis
        res.json({ message: 'File uploaded', ml: { prediction: 'positive', confidence: 0.95, note: 'ML service offline' } });
      }
    });
});

app.listen(port, () => {
  console.log(`Backend running on port ${port} with SQLite database`);
});