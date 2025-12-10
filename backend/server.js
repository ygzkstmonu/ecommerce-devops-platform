const express = require('express');
const app = express();
const PORT = process.env.PORT || 5000;

app.use(express.json());
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
  res.header('Access-Control-Allow-Headers', 'Content-Type');
  next();
});
app.get('/api/health', (req, res) => {
	res.json({
		status: 'healthy',
		timestamp: new Date().toISOString(),
		service: 'backend-api'
	});
});

app.get('/api/products', (req, res) => {
	res.json([
		{ id: 1, name: 'Laptop', price: 999 },
		{ id: 2, name: 'Mouse', price: 29},
		{ id: 3, name: 'Keyboard', price: 79}
	]);
});


app.get('/', (req, res) => {
	res.json({
		message: 'E-commerce Backend API',
		version: '1.0.0'
	});
});

app.listen(PORT, '0.0.0.0', () => {
	  console.log(`Backend API running on port ${PORT}`);
	});


