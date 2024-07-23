const express = require('express');
const bodyParser = require('body-parser');
const sqlite3 = require('sqlite3').verbose();
const jwt = require('jsonwebtoken');
const cors = require('cors');

const app = express();
app.use(bodyParser.json());
app.use(cors());

const db = new sqlite3.Database('./shopping_list.db');

db.serialize(() => {
  db.run(`CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE,
    password TEXT
  )`);

  db.run(`CREATE TABLE IF NOT EXISTS items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    userId INTEGER,
    name TEXT,
    quantity INTEGER,
    FOREIGN KEY (userId) REFERENCES users(id)
  )`);
});

app.post('/register', (req, res) => {
  const { username, password } = req.body;
  db.run(`INSERT INTO users (username, password) VALUES (?, ?)`, [username, password], function(err) {
    if (err) {
      return res.status(500).send({ message: 'User registration failed' });
    }
    res.send({ message: 'User registered successfully' });
  });
});

app.post('/login', (req, res) => {
  const { username, password } = req.body;
  db.get(`SELECT id, password FROM users WHERE username = ?`, [username], (err, row) => {
    if (err || !row || row.password !== password) {
      return res.status(401).send({ message: 'Invalid credentials' });
    }
    const token = jwt.sign({ userId: row.id }, 'secret_key');
    res.send({ token });
  });
});

const authMiddleware = (req, res, next) => {
  const token = req.headers['authorization'];
  if (!token) {
    return res.status(401).send({ message: 'No token provided' });
  }
  jwt.verify(token, 'secret_key', (err, decoded) => {
    if (err) {
      return res.status(401).send({ message: 'Invalid token' });
    }
    req.userId = decoded.userId;
    next();
  });
};

app.use(authMiddleware);

app.get('/items', (req, res) => {
  db.all(`SELECT * FROM items WHERE userId = ?`, [req.userId], (err, rows) => {
    if (err) {
      return res.status(500).send({ message: 'Failed to retrieve items' });
    }
    res.send(rows);
  });
});

app.post('/items', (req, res) => {
  const { name, quantity } = req.body;
  db.run(`INSERT INTO items (userId, name, quantity) VALUES (?, ?, ?)`, [req.userId, name, quantity], function(err) {
    if (err) {
      return res.status(500).send({ message: 'Failed to add item' });
    }
    res.send({ id: this.lastID });
  });
});

app.put('/items/:id', (req, res) => {
  const { id } = req.params;
  const { name, quantity } = req.body;
  db.run(`UPDATE items SET name = ?, quantity = ? WHERE id = ? AND userId = ?`, [name, quantity, id, req.userId], function(err) {
    if (err) {
      return res.status(500).send({ message: 'Failed to update item' });
    }
    res.send({ message: 'Item updated successfully' });
  });
});

app.delete('/items/:id', (req, res) => {
  const { id } = req.params;
  db.run(`DELETE FROM items WHERE id = ? AND userId = ?`, [id, req.userId], function(err) {
    if (err) {
      return res.status(500).send({ message: 'Failed to delete item' });
    }
    res.send({ message: 'Item deleted successfully' });
  });
});

app.listen(3000, () => {
  console.log('Server is running on port 3000');
});
