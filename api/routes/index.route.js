const express = require('express');
const router = express.Router();

/**
 * GET
 */
router.get('/', (req, res) => {
  res.json({ message: 'healthy' });
});

module.exports = router;
