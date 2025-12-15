// ============================================
// E-Commerce Backend API with PostgreSQL
// ============================================

// Import required modules
const express = require('express');         // Web framework
const pool = require('./database/db');      // PostgreSQL connection pool
const client = require('prom-client');      // Prometheus metrics client

const app = express();
const PORT = process.env.PORT || 5000;      // Port from env variable or default 5000

// ============================================
// PROMETHEUS METRICS SETUP
// ============================================

// Create a Registry to register the metrics
const register = new client.Registry();

// Add default metrics (CPU, memory, event loop lag, etc.)
client.collectDefaultMetrics({ register });

// Custom metric: HTTP request counter
const httpRequestCounter = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'path', 'status'],
  registers: [register]
});

// Custom metric: HTTP request duration
const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'path', 'status'],
  registers: [register]
});

// Custom metric: Database query counter
const dbQueryCounter = new client.Counter({
  name: 'db_queries_total',
  help: 'Total number of database queries',
  labelNames: ['query_type'],
  registers: [register]
});

// Custom metric: Active database connections
const dbConnectionsGauge = new client.Gauge({
  name: 'db_connections_active',
  help: 'Number of active database connections',
  registers: [register]
});

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

// Metrics middleware - Track all HTTP requests
app.use((req, res, next) => {
  const start = Date.now();  // Record start time

  // Override res.end to capture response
  const originalEnd = res.end;
  res.end = function(...args) {
    const duration = (Date.now() - start) / 1000;  // Calculate duration in seconds

    // Increment request counter
    httpRequestCounter.inc({
      method: req.method,
      path: req.path,
      status: res.statusCode
    });

    // Record request duration
    httpRequestDuration.observe({
      method: req.method,
      path: req.path,
      status: res.statusCode
    }, duration);

    // Call original end function
    originalEnd.apply(res, args);
  };

  next();
});

// ============================================
// ROUTES / ENDPOINTS
// ============================================

/**
 * Prometheus Metrics Endpoint
 * GET /metrics
 * Returns metrics in Prometheus format
 */
app.get('/metrics', async (req, res) => {
  try {
    // Update database connections gauge
    const poolInfo = await pool.query('SELECT count(*) FROM pg_stat_activity WHERE datname = $1', [process.env.DB_NAME || 'ecommerce']);
    dbConnectionsGauge.set(parseInt(poolInfo.rows[0].count));

    // Set content type for Prometheus
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
  } catch (error) {
    res.status(500).end(error.message);
  }
});

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
    // Increment database query counter
    dbQueryCounter.inc({ query_type: 'select_products' });

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
    version: '3.0.0',
    endpoints: {
      health: '/api/health',
      products: '/api/products',
      metrics: '/metrics'
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
