// ########################################
// ########## SETUP

// Express
const express = require('express');
const app = express();

app.use((req, res, next) => {
  console.log(`[REQ] ${req.method} ${req.url}`);
  next();
});

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

const PORT = 13978;

// Database
const db = require('./database/db-connector');

// Handlebars
const { engine } = require('express-handlebars'); // // Create instance of handlebars and import express-handlebars engine
app.engine('.hbs', engine({
  extname: '.hbs',
  helpers: {
    ifEquals: function (a, b, options) {
      return (a == b) ? options.fn(this) : options.inverse(this);
    },
    ifNotEquals: function (a, b, options) {
      return (a != b) ? options.fn(this) : options.inverse(this);
    }
  }
}));


app.set('view engine', '.hbs'); // Use handlebars engine for *.hbs files.
// Static Files (for CSS)
// app.use(express.static('public'));
app.set('views', __dirname + '/views');


// ########################################
// ########## ROUTE HANDLERS

// index page
app.get('/', function(req, res){
    console.log('1st default route hit'); 
    res.render('index');
    console.log('2nd default route hit'); 
});


// POST reset route
app.post('/reset', async function(req, res){
  try {
    await db.query('CALL sp_reset_schema_and_data();');
    // After reset, redirect back to index with a success message
    res.render('index', { message: 'Database has been reset successfully.' });
  } catch (err) {
    console.error(err);
    res.render('index', { error: 'Database reset failed.' });
  }
});

// Universities Page
app.get('/universities', async function(req, res){
  try {
    const [rows] = await db.query('CALL select_universities();');
     res.render('universities', { universities: rows[0] });
  } catch (err) {
    console.error(err);
    res.render('universities', { error: 'Database error' });
  }
});

// Universities Page add route
app.post('/universities/add', async function(req, res){
  const { 
    universityName, location, campusType, acceptanceRate, athleticClassification,
    fees, boarding, meals, books, inStateTuition, outOfStateTuition
  } = req.body;

  try {
    await db.query('CALL add_university(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
      universityName, location, campusType, acceptanceRate, athleticClassification,
      fees, boarding, meals, books, inStateTuition, outOfStateTuition
    ]);
    res.redirect('/universities');
  } catch (err) {
    console.error(err);
    res.render('universities', { error: 'Failed to add this University' });
  }
});


// Athletics page
app.get('/athletics', async (req, res) => {
  const universityID = parseInt(req.query.universityID) || 1;
  try {
    // Call the procedure with the selected universityID
    const [rows] = await db.query('CALL display_sports_by_institution(?);', [universityID]);

    // Fetch universities for dropdown
    const [universities] = await db.query('CALL select_universities();');

    res.render('athletics', {
      athletics: rows[0],          // sports list for selected university
      universities: universities[0], // dropdown options
      selectedID: universityID     // keep selection highlighted
    });
  } catch (err) {
    console.error(err);
    res.render('athletics', { error: 'Database error' });
  }
});


// Majors Page
app.get('/majors', async function(req, res){
  const universityID = parseInt(req.query.universityID) || 1; // default to OSU
  try {
    // Call procedure with selected universityID
    const [majors] = await db.query('CALL select_majors_by_institution(?);', [universityID]);

    // Fetch universities for dropdown
    const [universities] = await db.query('CALL select_universities();');

    res.render('majors', {
      majors: majors[0],            // majors list for selected university
      universities: universities[0],// dropdown options
      selectedID: universityID      // keep selection highlighted
    });
  } catch (err) {
    console.error(err);
    res.render('majors', { error: 'Database error' });
  }
});

// Add a major to a university
app.post('/majors/add', async function(req, res){
  const { universityID, majorID } = req.body;
  try {
    await db.query('CALL add_major_to_institution(?, ?)', [universityID, majorID]);
    // reload majors page for same university
    res.redirect('/majors?universityID=' + universityID);
  } catch (err) {
    console.error(err);
    res.render('majors', { error: 'Failed to add major' });
  }
});

// Remove a major from a university
app.post('/majors/remove', async function(req, res){
  const { universityID, majorID } = req.body;
  try {
    await db.query('CALL remove_major_from_institution(?, ?)', [universityID, majorID]);
    // reload majors page for same university
    res.redirect('/majors?universityID=' + universityID);
  } catch (err) {
    console.error(err);
    res.render('majors', { error: 'Failed to remove major' });
  }
});



// Costs page
app.get('/costs', async function(req, res){
  const universityID = parseInt(req.query.universityID) || 1; // default is 1 if not provided
  try {
    const [rows] = await db.query('CALL select_cost_by_institution(?);', [universityID]);
    const [universities] = await db.query('CALL select_universities();'); // dropdown
    res.render('costs', {
      costs: rows[0],
      universities: universities[0],
      selectedID: universityID
    });
  } catch (err) {
    console.error(err);
    res.render('costs', { error: 'Database error' });
  }
});

// Update costs
app.post('/costs/update', async function(req, res){
  const { fees, boarding, meals, books, universityID } = req.body;
  try {
    await db.query('CALL update_cost_details(?, ?, ?, ?, ?)', 
      [fees, boarding, meals, books, universityID]);
    res.redirect('/costs?universityID=' + universityID); // reload with updated record
  } catch (err) {
    console.error(err);
    res.render('costs', { error: 'Failed to update costs' });
  }
});


 
// Tuition page
app.get('/tuition', async function(req, res){
  const universityID = parseInt(req.query.universityID) || 1; // default to 1 if none selected
  try {
    const [rows] = await db.query('CALL select_cost_by_institution(?);', [universityID]);

    // fetch universities for dropdown
    const [universities] = await db.query('CALL select_universities();');

    res.render('tuition', {
      tuition: rows[0],               // result set from procedure
      universities: universities[0],  // dropdown options
      selectedID: universityID        // keep selection highlighted
    });
  } catch (err) {
    console.error(err);
    res.render('tuition', { error: 'Database error' });
  }
});

// Tuition update route
app.post('/tuition/update', async function(req, res){
  const { inStateTuition, outOfStateTuition, universityID } = req.body;
  try {
    await db.query('CALL update_tuition_details(?, ?, ?)', [
      inStateTuition,
      outOfStateTuition,
      universityID
    ]);
    // reload page with updated tuition for the same university
    res.redirect('/tuition?universityID=' + universityID);
  } catch (err) {
    console.error(err);
    res.render('tuition', { error: 'Failed to update tuition' });
  }
});


// Universities-Has-Athletics page
app.get('/universities_has_athletics', async function(req, res){
  try {
    const [rows] = await db.query('CALL select_universities_has_athletics();');
    res.render('universities_has_athletics', { assignments: rows[0] });
  } catch (err) {
    console.error(err);
    res.render('universities_has_athletics', { error: 'Database error' });
  }
});



// Universities-Has-Majors page
app.get('/universities_has_majors', async function(req, res){
  const universityID = parseInt(req.query.universityID) || 1; // default to 1
  try {
    // majors assigned to the selected university
    const [assignments] = await db.query('CALL select_majors_by_institution(?);', [universityID]);

    // for dropdowns
    const [universities] = await db.query('CALL select_universities();');
    const [majors] = await db.query('CALL select_majors();');

    res.render('universities_has_majors', { 
      assignments: assignments[0],   // majors for selected university
      universities: universities[0], // dropdown option
      majors: majors[0],             // dropdown option
      selectedID: universityID       // keep selected university highlighted
    });
  } catch (err) {
    console.error(err);
    res.render('universities_has_majors', { error: 'Database error' });
  }
});



// ########################################
// ########## LISTENER

app.listen(PORT, function () {
    console.log(
        'Express started on http://localhost:' +
            PORT +
            '; press Ctrl-C to terminate.'
    );
    
  // listRoutes(app); // <-- Now runs after everything is set up

});