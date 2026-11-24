const express = require('express');
const cors = require('cors');
const userRoutes = require('./routes/user.routes');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/', (req, res) => res.json({ message: 'API berjalan' }));
app.use('/api/users', userRoutes);

module.exports = app;