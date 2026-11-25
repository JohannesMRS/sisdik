const express = require('express');
const { query } = require('../config/db');

const router = express.Router();

router.get('/health', async (req, res) => {
  try {
    await query('SELECT 1');
    res.json({ data: { status: 'ok', db: 'up' } });
  } catch (error) {
    res.status(503).json({
      error: {
        code: 'SERVICE_UNAVAILABLE',
        message: 'Layanan database tidak tersedia.',
        details: [],
      },
    });
  }
});

module.exports = router;
