// Database connection test
const pool = require('../database/db');

async function testDatabaseConnection() {
  try {
    console.log('Testing database connection...');
    
    // Test 1: Basic connection
    const result = await pool.query('SELECT NOW()');
    console.log('Database connection successful');
    console.log('   Server time:', result.rows[0].now);
    
    // Test 2: Check if products table exists
    const tableCheck = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'products'
      );
    `);
    
    if (tableCheck.rows[0].exists) {
      console.log(' Products table exists');
    } else {
      throw new Error('Products table not found');
    }
    
    // Test 3: Check if we have sample data
    const countResult = await pool.query('SELECT COUNT(*) FROM products');
    const count = parseInt(countResult.rows[0].count);
    
    if (count >= 5) {
      console.log(`Sample data exists (${count} products)`);
    } else {
      throw new Error(`Expected at least 5 products, found ${count}`);
    }
    
    console.log('All database tests passed!');
    process.exit(0);
    
  } catch (error) {
    console.error('Database test failed:', error.message);
    process.exit(1);
  }
}

// Run tests
testDatabaseConnection();
