const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const healthRoutes = require('../src/routes/health.routes');
const { notFoundHandler, errorHandler } = require('../src/middlewares/errorHandler');

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: false, limit: '1mb' }));

if (process.env.NODE_ENV !== 'test') {
  app.use(morgan('combined', {
    skip: (req) => req.path.includes('/password') || req.path.includes('/auth'),
  }));
}

app.use('/api/v1', healthRoutes);
app.use(notFoundHandler);
app.use(errorHandler);

module.exports = app;