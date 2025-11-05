const express = require('express');
const router = express.Router();
const db = require('../db-connector');

router.get('/universities_has_majors', (req, res) => {
  db.query('SELECT universityID, universityName FROM UNIVERSITIES', (err, uniResults) => {
    if (err) return res.status(500).send(err);
    db.query('SELECT majorID, program FROM MAJORS', (err, majorResults) => {
      if (err) return res.status(500).send(err);
      db.query(`SELECT U.universityName, M.program 
                FROM UNIVERSITIES_HAS_MAJORS UH 
                JOIN UNIVERSITIES U ON UH.universityID = U.universityID 
                JOIN MAJORS M ON UH.majorID = M.majorID`, (err, joinedResults) => {
        if (err) return res.status(500).send(err);
        res.render('universities_has_majors', {
          universities: uniResults,
          majors: majorResults,
          offerings: joinedResults
        });
      });
    });
  });
});

router.post('/add-university-major', (req, res) => {
  const { universityID, majorID } = req.body;
  db.query('CALL insertUniversityMajor(?, ?)', [universityID, majorID], err => {
    if (err) return res.status(500).send(err);
    res.redirect('/universities_has_majors');
  });
});

module.exports = router;