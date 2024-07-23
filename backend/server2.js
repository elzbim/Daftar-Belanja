const express = require('express');
const bodyParser = require('body-parser');
const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database(':memory:');
const app = express();
const PORT = process.env.PORT || 5000;

app.use(bodyParser.json());

db.serialize(() => {
  db.run("CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT, fcmToken TEXT)");
  db.run("CREATE TABLE items (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, quantity INTEGER, price INTEGER)");
});

app.post('/save-token', (req, res) => {
  const { username, token } = req.body;

  db.run("UPDATE users SET fcmToken = ? WHERE username = ?", [token, username], function(err) {
    if (err) {
      console.error('Error saving token:', err.message);
      return res.status(500).send('Internal Server Error');
    }
    res.status(200).send('Token saved successfully');
  });
});

app.post('/register', (req, res) => {
  const { username, password } = req.body;
  db.run("INSERT INTO users (username, password) VALUES (?, ?)", [username, password], function(err) {
    if (err) {
      return res.status(500).send(err.message);
    }
    res.status(200).send({ id: this.lastID });
  });
});

app.post('/login', (req, res) => {
  const { username, password } = req.body;
  db.get("SELECT * FROM users WHERE username = ? AND password = ?", [username, password], (err, row) => {
    if (err) {
      return res.status(500).send(err.message);
    }
    if (row) {
      res.status(200).send(row);
    } else {
      res.status(400).send("Invalid credentials");
    }
  });
});

app.get('/items', (req, res) => {
  db.all("SELECT * FROM items", [], (err, rows) => {
    if (err) {
      return res.status(500).send(err.message);
    }
    res.status(200).send(rows);
  });
});

app.post('/items', (req, res) => {
  const { name, quantity, price } = req.body;
  db.run("INSERT INTO items (name, quantity, price) VALUES (?, ?, ?)", [name, quantity, price], function(err) {
    if (err) {
      return res.status(500).send(err.message);
    }
    res.status(200).send({ id: this.lastID });
  });
});

app.put('/items/:id', (req, res) => {
  const { id } = req.params;
  const { name, quantity, price } = req.body;
  db.run("UPDATE items SET name = ?, quantity = ?, price = ? WHERE id = ?", [name, quantity, price, id], function(err) {
    if (err) {
      return res.status(500).send(err.message);
    }
    res.status(200).send("Item updated");
  });
});

app.delete('/items/:id', (req, res) => {
  const { id } = req.params;
  db.run("DELETE FROM items WHERE id = ?", [id], function(err) {
    if (err) {
      return res.status(500).send(err.message);
    }
    res.status(200).send("Item deleted");
  });
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
