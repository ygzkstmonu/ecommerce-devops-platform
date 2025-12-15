// ============================================
// E-Commerce Backend API with PostgreSQL
// ============================================

// Import required modules
const express = require('express');         // Web framework
const pool = require('./database/db');      // PostgreSQL connection pool

const app = express();
const PORT = process.env.PORT || 5000;      // Port from env variable or default 5000

// ============================================
// MIDDLEWARE
// ============================================

// Parse incoming JSON requests
app.use(express.json());

// CORS - Allow requests from any origin
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');               // Allow all origins
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');  // Allowed methods
  res.header('Access-Control-Allow-Headers', 'Content-Type');   // Allowed headers
  next();  // Pass to next middleware
});

// ============================================
// ROUTES / ENDPOINTS
// ============================================

/**
 * Health Check Endpoint
 * GET /api/health
 * Tests database connection and returns server status
 */
app.get('/api/health', async (req, res) => {
  try {
    // Query database to get current time (tests connection)
    const result = await pool.query('SELECT NOW()');
    
    res.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      service: 'backend-api',
      database: 'connected',
      db_time: result.rows[0].now
    });
  } catch (error) {
    // If database connection fails, return error
    res.status(500).json({
      status: 'unhealthy',
      error: error.message,
      database: 'disconnected'
    });
  }
});

/**
 * Get All Products
 * GET /api/products
 * Retrieves all products from database, ordered by newest first
 */
app.get('/api/products', async (req, res) => {
  try {
    // Query all products, sorted by creation date (newest first)
    const result = await pool.query(
      'SELECT * FROM products ORDER BY created_at DESC'
    );
    
    // Return success response with product data
    res.json({
      success: true,
      count: result.rows.length,    // Number of products
      data: result.rows              // Array of products
    });
  } catch (error) {
    // Log error to server console
    console.error('Error fetching products:', error);
    
    // Return error response to client
    res.status(500).json({
      success: false,
      error: 'Failed to fetch products'
    });
  }
});

/**
 * Root Endpoint
 * GET /
 * Returns API information and available endpoints
 */
app.get('/', (req, res) => {
  res.json({
    message: 'E-commerce Backend API with PostgreSQL',
    version: '2.0.0',
    endpoints: {
      health: '/api/health',
      products: '/api/products'
    }
  });
});

// ============================================
// START SERVER
// ============================================

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Backend API running on port ${PORT}`);
  console.log(`PostgreSQL connection configured`);
});
