const express = require('express');

const app = express();
const PORT = process.env.PORT || 8082;

app.use(express.json());

const PRODUCTS = [
  { id: 1, title: 'Ultra-light Performance Mechanical Keyboard', price: 129.99, stock: 45 },
  { id: 2, title: 'Ergonomic Mesh High-Back Office Chair', price: 289.00, stock: 12 },
  { id: 3, title: 'Noise-Cancelling Studio Wireless Headphones', price: 199.50, stock: 80 }
];

app.get('/health', (req, res) => {
  res.json({
    status: 'UP',
    service: 'product-service',
    timestamp: new Date().toISOString()
  });
});

app.get('/api/v1/products', (req, res) => {
  res.json({ products: PRODUCTS, count: PRODUCTS.length });
});

app.get('/api/v1/products/:id', (req, res) => {
  const item = PRODUCTS.find(p => p.id === parseInt(req.params.id));
  if (!item) {
    return res.status(404).json({ error: 'Product not found' });
  }
  res.json(item);
});

app.listen(PORT, () => {
  console.log(`[product-service] Running on port ${PORT}`);
});
