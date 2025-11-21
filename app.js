// ########################################
// ########## SETUP

const express = require('express');
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));
// const mysql = require('mysql2/promise');  

// Database
const db = require('./database/db-connector');

// Handlebars
const handlebars = require('express-handlebars').create({
  defaultLayout: 'main',
  extname: 'hbs'
});
app.engine('hbs', handlebars.engine);
app.set('view engine', 'hbs');

// Port
const PORT = 14222;

// Static Files
app.use(express.static('public'));
app.use(express.urlencoded({ extended: true }));  

// ########################################
// ########## ROUTE HANDLERS

// ROUTES

// Index page
app.get('/', (req, res) => {
  res.render('index');
});

// Universities Page (Select)
app.get('/universities', async (req, res) => {
  try {
    const [rows] = await db.query('CALL select_universities()');
    res.render('universities', { universities: rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).send('Database error');
  }
});

// Majors page (Select)
app.get('/majors', async (req, res) => {
  try {
    const universityID = req.query.universityID || 1;
    const [rows] = await db.query('CALL select_majors_by_institution(?)', [universityID]);
    res.render('majors', { majors: rows[0], universityID });
  } catch (err) {
    console.error(err);
    res.status(500).send('Database error');
  }
});

// add major (Insert)
app.post('/majors/add', async (req, res) => {
  const { universityID, majorID } = req.body;
  try {
    await db.query('CALL add_major_to_institution(?, ?)', [universityID, majorID]);
    res.redirect('/majors?universityID=' + universityID);
  } catch (err) {
    console.error(err);
    res.status(500).send('Insert error');
  }
});

// change major name (update)
app.post('/majors/change', async (req, res) => {
  const { majorID, newName } = req.body;
  try {
    await db.query('CALL change_major_name(?, ?)', [newName, majorID]);
    res.redirect('/majors');
  } catch (err) {
    console.error(err);
    res.status(500).send('Update error');
  }
});

// remove major (Delete)
app.post('/majors/remove', async (req, res) => {
  const { universityID, majorID } = req.body;
  try {
    await db.query('CALL remove_major_from_institution(?, ?)', [universityID, majorID]);
    res.redirect('/majors?universityID=' + universityID);
  } catch (err) {
    console.error(err);
    res.status(500).send('Delete error');
  }
});

// Athletics page (select)
app.get('/athletics', async (req, res) => {
  try {
    const universityID = req.query.universityID || 1;
    const [rows] = await db.query('CALL display_sports_by_institution(?)', [universityID]);
    res.render('athletics', { athletics: rows[0], universityID });
  } catch (err) {
    console.error(err);
    res.status(500).send('Database error');
  }
});

// add sport (Insert)
app.post('/athletics/add', async (req, res) => {
  const { universityID, sportID } = req.body;
  try {
    await db.query('CALL add_sport_to_institution(?, ?)', [universityID, sportID]);
    res.redirect('/athletics?universityID=' + universityID);
  } catch (err) {
    console.error(err);
    res.status(500).send('Insert error');
  }
});

// Remove Sport (Delete)
app.post('/athletics/remove', async (req, res) => {
  const { universityID, sportID } = req.body;
  try {
    await db.query('CALL remove_sport_from_institution(?, ?)', [universityID, sportID]);
    res.redirect('/athletics?universityID=' + universityID);
  } catch (err) {
    console.error(err);
    res.status(500).send('Delete error');
  }
});

// Costs page
app.get('/costs', async (req, res) => {
  try {
    const universityID = req.query.universityID || 1;
    const [rows] = await db.query('CALL select_cost_by_institution(?)', [universityID]);
    res.render('costs', { costs: rows[0], universityID });
  } catch (err) {
    console.error(err);
    res.status(500).send('Database error');
  }
});

// update costs  
app.post('/costs/update', async (req, res) => {
  const { fees, boarding, meals, books, universityID } = req.body;
  try {
    await db.query('CALL update_cost_details(?, ?, ?, ?, ?)', [fees, boarding, meals, books, universityID]);
    res.redirect('/costs?universityID=' + universityID);
  } catch (err) {
    console.error(err);
    res.status(500).send('Update error');
  }
});

// Tuition page (SELECT via costs join)
app.get('/tuition', async (req, res) => {
  try {
    const universityID = req.query.universityID || 1;
    const [rows] = await db.query('CALL select_cost_by_institution(?)', [universityID]);
    res.render('tuition', { tuition: rows[0], universityID });
  } catch (err) {
    console.error(err);
    res.status(500).send('Database error');
  }
});

// update Tuition 
app.post('/tuition/update', async (req, res) => {
  const { inStateTuition, outStateTuition, costsID } = req.body;
  try {
    await db.query('CALL update_tuition_details(?, ?, ?)', [inStateTuition, outStateTuition, costsID]);
    res.redirect('/tuition');
  } catch (err) {
    console.error(err);
    res.status(500).send('Update error');
  }
});

// add university (Insert)
app.post('/universities/add', async (req, res) => {
  const { universityName, location, campusType, acceptanceRate, athleticClassification } = req.body;
  try {
    await db.query('CALL add_university(?, ?, ?, ?, ?)', 
      [universityName, location, campusType, acceptanceRate, athleticClassification]);
    res.redirect('/universities');
  } catch (err) {
    console.error(err);
    res.status(500).send('Insert error');
  }
});

// update university (Update)
app.post('/universities/update', async (req, res) => {
  const { universityID, universityName, location, campusType, acceptanceRate, athleticClassification } = req.body;
  try {
    await db.query('CALL update_university(?, ?, ?, ?, ?, ?)', 
      [universityID, universityName, location, campusType, acceptanceRate, athleticClassification]);
    res.redirect('/universities');
  } catch (err) {
    console.error(err);
    res.status(500).send('Update error');
  }
});

// remove university (Delete)
app.post('/universities/remove', async (req, res) => {
  const { universityID } = req.body;
  try {
    await db.query('CALL remove_university(?)', [universityID]);
    res.redirect('/universities');
  } catch (err) {
    console.error(err);
    res.status(500).send('Delete error');
  }
});

// RESET the entire database  
app.post('/reset', async (req, res) => {
  try {
    // procedure drops drops and rebuilds schema, then reloads sample data
    await db.query('CALL sp_reset_schema_and_data()');
    
    // redirect back to homepage
    res.redirect('/');
    
    // possibile future implementation render a confirmation page instead
    // res.render('reset', { message: 'Database reset successfully!' });
  } catch (err) {
    console.error(err);
    res.status(500).send('Reset error');
  }
});

// ########################################
// ########## LISTENER

app.listen(PORT, () => {
  console.log('Express started on http://localhost:' + PORT + '; press Ctrl-C to terminate.');
});