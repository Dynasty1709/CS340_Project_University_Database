const express = require('express');
const router = express.Router();
const db = require('../db-connector');

router.post('/reset-database', (req, res) => {
  db.query('CALL resetDatabase()', err => {
    if (err) return res.status(500).send(err);
    res.redirect('/');
  });
});

module.exports = router;