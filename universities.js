const express = require('express');
const router = express.Router();
const db = require('../db-connector');

router.get('/universities', (req, res) => {
  db.query('SELECT universityID, universityName FROM UNIVERSITIES', (err, results) => {
    if (err) return res.status(500).send(err);
    res.render('universities', { universities: results });
  });
});

module.exports = router;