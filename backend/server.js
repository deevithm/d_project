const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const sqlite3 = require('sqlite3').verbose();
const { v4: uuidv4 } = require('uuid');
const path = require('path');

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Initialize SQLite database
const db = new sqlite3.Database(':memory:');

// Create tables
db.serialize(() => {
  // Users table
  db.run(`CREATE TABLE users (
    id TEXT PRIMARY KEY,
    email TEXT UNIQUE,
    name TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )`);

  // Machines table
  db.run(`CREATE TABLE machines (
    id TEXT PRIMARY KEY,
    name TEXT,
    location TEXT,
    status TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )`);

  // Orders table
  db.run(`CREATE TABLE orders (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    machine_id TEXT,
    total_amount REAL,
    payment_method TEXT,
    status TEXT,
    items TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )`);

  // Insert sample data
  const sampleMachines = [
    { id: 'store_001', name: 'Tech Mall Store', location: 'Tech Mall, Bangalore', status: 'online' },
    { id: 'store_002', name: 'Metro Station Store', location: 'MG Road Metro, Bangalore', status: 'online' },
    { id: 'store_003', name: 'College Campus Store', location: 'IIT Campus, Bangalore', status: 'maintenance' }
  ];

  sampleMachines.forEach(machine => {
    db.run('INSERT INTO machines (id, name, location, status) VALUES (?, ?, ?, ?)',
      [machine.id, machine.name, machine.location, machine.status]);
  });

  // Insert sample user
  db.run('INSERT INTO users (id, email, name) VALUES (?, ?, ?)',
    ['user_001', 'demo@snackly.com', 'Demo User']);
});

// API Routes

// Health check
app.get('/api/v1/health', (req, res) => {
  res.json({ status: 'ok', message: 'Snackly Backend is running!' });
});

// Get all machines
app.get('/api/v1/machines', (req, res) => {
  db.all('SELECT * FROM machines', [], (err, rows) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json({ machines: rows });
  });
});

// Get machine by ID
app.get('/api/v1/machines/:id', (req, res) => {
  const { id } = req.params;
  db.get('SELECT * FROM machines WHERE id = ?', [id], (err, row) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    if (!row) {
      res.status(404).json({ error: 'Machine not found' });
      return;
    }
    res.json({ machine: row });
  });
});

// Get products for a machine
app.get('/api/v1/machines/:id/products', (req, res) => {
  // For demo, return the same product list for all machines
  const products = [
    {
      id: 'bev_001',
      name: 'Coca Cola',
      category: 'beverages',
      price: 40.0,
      description: 'Refreshing cola drink - 330ml can',
      inStock: true,
      stock: 15
    },
    {
      id: 'snk_001',
      name: 'Lays Classic',
      category: 'snacks',
      price: 25.0,
      description: 'Classic salted potato chips - 52g pack',
      inStock: true,
      stock: 8
    },
    {
      id: 'hlt_001',
      name: 'Amul Fresh Milk',
      category: 'healthy',
      price: 30.0,
      description: 'Fresh dairy milk - 500ml pack',
      inStock: true,
      stock: 5
    }
  ];
  
  res.json({ products });
});

// Create order
app.post('/api/v1/orders', (req, res) => {
  const { machineId, userId = 'user_001', items, totalAmount, paymentMethod } = req.body;
  
  const orderId = uuidv4();
  const status = 'confirmed';
  const itemsJson = JSON.stringify(items);
  
  db.run(
    'INSERT INTO orders (id, user_id, machine_id, total_amount, payment_method, status, items) VALUES (?, ?, ?, ?, ?, ?, ?)',
    [orderId, userId, machineId, totalAmount, paymentMethod, status, itemsJson],
    function(err) {
      if (err) {
        res.status(500).json({ error: err.message });
        return;
      }
      
      res.json({
        order: {
          id: orderId,
          userId,
          machineId,
          totalAmount,
          paymentMethod,
          status,
          items,
          createdAt: new Date().toISOString()
        }
      });
    }
  );
});

// Get orders for user
app.get('/api/v1/orders', (req, res) => {
  const userId = req.query.userId || 'user_001';
  
  db.all('SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC', [userId], (err, rows) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    
    const orders = rows.map(row => ({
      ...row,
      items: JSON.parse(row.items)
    }));
    
    res.json({ orders });
  });
});

// Get order by ID
app.get('/api/v1/orders/:id', (req, res) => {
  const { id } = req.params;
  
  db.get('SELECT * FROM orders WHERE id = ?', [id], (err, row) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    if (!row) {
      res.status(404).json({ error: 'Order not found' });
      return;
    }
    
    const order = {
      ...row,
      items: JSON.parse(row.items)
    };
    
    res.json({ order });
  });
});

// ML Predictions (Mock)
app.get('/api/v1/ml/predictions/demand', (req, res) => {
  res.json({
    predictions: [
      { product: 'Coca Cola', demand: 85, confidence: 0.92 },
      { product: 'Lays Classic', demand: 72, confidence: 0.88 },
      { product: 'Amul Milk', demand: 45, confidence: 0.75 }
    ]
  });
});

app.get('/api/v1/ml/predictions/pricing', (req, res) => {
  res.json({
    suggestions: [
      { product: 'Coca Cola', currentPrice: 40, suggestedPrice: 42, reason: 'High demand' },
      { product: 'Lays Classic', currentPrice: 25, suggestedPrice: 23, reason: 'Promotional boost' }
    ]
  });
});

// Admin Dashboard
app.get('/api/v1/admin/dashboard', (req, res) => {
  res.json({
    stats: {
      totalSales: 15420,
      totalOrders: 342,
      activeMachines: 2,
      revenue: {
        today: 1240,
        week: 8950,
        month: 35600
      }
    }
  });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'API endpoint not found' });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Snackly Backend running on http://localhost:${PORT}`);
  console.log(`📱 Health check: http://localhost:${PORT}/api/v1/health`);
  console.log(`🛒 Machines: http://localhost:${PORT}/api/v1/machines`);
  console.log(`📦 Orders: http://localhost:${PORT}/api/v1/orders`);
});

module.exports = app;