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

const PORT = 14223;

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
     await db.query('SELECT 1');
	res.render('universities', { universities: rows[0] });
  } catch (err) {
    console.error(err);
    res.render('universities', { error: 'Database error' });
  }
});

// Universities Page add route
app.post('/universities/add', async function(req, res){
  const { 
    universityName, location, campusType, acceptanceRate, athleticClassification
  } = req.body;

  try {
    await db.query('CALL add_university(?, ?, ?, ?, ?)', [
      universityName, location, campusType, acceptanceRate, athleticClassification
    ]);
	await db.query('SELECT 1;');
    res.redirect('/universities');
  } catch (err) {
    console.error(err);
    res.render('universities', { error: 'Failed to add this University' });
  }
});
// POST route to update an existing university record
app.post('/universities/update', async function(req, res){
    
    const { 
        universityID, 
        universityName, 
        location, 
        campusType, 
        acceptanceRate, 
        athleticClassification 
    } = req.body;

    try {
        await db.query('CALL update_university(?, ?, ?, ?, ?, ?)', [
            universityID,
            universityName,
            location,
            campusType,
            acceptanceRate,
            athleticClassification
        ]);
        res.redirect('/universities');
    } catch (err) {
        console.error("Error updating university:", err);
        res.render('universities', { error: 'Failed to update University details.' });
    }
});
app.post('/universities/remove', async function(req, res){
    // The universityID comes from a hidden input in the form
    const { universityID } = req.body; 
    try {
        await db.query('CALL remove_university(?)', [universityID]);
        // Redirect back to the universities page after deletion
        res.redirect('/universities');
    } catch (err) {

        console.error(err);
        res.render('universities', { error: 'Failed to delete University' });
    }
});
// Athletics page
app.get('/athletics', async (req, res) => {
  
  try {
    // Call the procedure with the selected universityID
    const [rows] = await db.query('CALL select_sports();');

    // Fetch universities for dropdown
    const [universities] = await db.query('CALL select_universities();');

    res.render('athletics', {
      athletics: rows[0],          // sports list for selected university
      universities: universities[0], // dropdown options
      
    });
  } catch (err) {
    console.error(err);
    res.render('athletics', { error: 'Database error' });
  }
});
app.post('/athletics/remove', async function(req, res) {
    const {sportID } = req.body; 
    
    try {
        await db.query('CALL remove_sport(?)', [sportID]);

        res.redirect('/athletics'); 
    } catch (err) {
        console.error("Error removing athletics assignment:", err);
        res.render('athletics', { error: 'Failed to remove sport assignment.' });
    }
});
app.post('/athletics/add', async function(req, res){
    const { sportName, sportType } = req.body;
    try {
        await db.query('CALL add_sport(?, ?)', [sportName, sportType]);
        await db.query('SELECT 1;'); 

        res.redirect('/athletics');
    } catch (err) {
        console.error("Error adding sport:", err);
        res.render('athletics', { error: 'Failed to add new Sport' });
    }
});
app.post('/athletics/update', async function(req, res){
    const { sportID, sportName, sportType } = req.body;
    try {
        await db.query('CALL update_sport(?, ?, ?)', [sportID, sportName, sportType]);
        await db.query('SELECT 1;'); 

        res.redirect('/athletics');
    } catch (err) {
        console.error("Error updating sport:", err);
        res.render('athletics', { error: 'Failed to update Sport details' });
    }
});
// Majors Page
app.get('/majors', async function(req, res){
  
  try {
    // Call procedure with selected universityID
    const [majors] = await db.query('CALL select_majors();');

    // Fetch universities for dropdown
    const [universities] = await db.query('CALL select_universities();');

    res.render('majors', {
      majors: majors[0],            // majors list for selected university
      universities: universities[0],// dropdown options
      
    });
  } catch (err) {
    console.error(err);
    res.render('majors', { error: 'Database error' });
  }
});

// Add a major to a university
app.post('/majors/add', async function(req, res){
    const { program, level } = req.body;
    try {
        await db.query('CALL add_major(?, ?)', [program, level]);
        res.redirect('/majors');
    } catch (err) {
        console.error("Error adding major:", err);
        res.render('majors', { error: 'Failed to add new Major' });
    }
});
app.post('/majors/update', async function(req, res){
    const { majorID, program, level } = req.body;
    try {
        await db.query('CALL update_major(?, ?, ?)', [majorID, program, level]);
        res.redirect('/majors');
    } catch (err) {
        console.error("Error updating major:", err);
        res.render('majors', { error: 'Failed to update Major details' });
    }
});
// Remove a major from a university
app.post('/majors/remove', async function(req, res){
    const { majorID } = req.body;
    try {
        await db.query('CALL remove_major(?)', [majorID]);
        res.redirect('/majors');
    } catch (err) {
        console.error("Error deleting major:", err);
        res.render('majors', { error: 'Failed to delete Major' });
    }
});



// Costs page
app.get('/costs', async function(req, res){
  try {
    const [rows] = await db.query('CALL select_cost_by_institution(?);', [null]);
    const [universities] = await db.query('CALL select_universities();'); // dropdown
    const [availableUniversities] = await db.query(
        `SELECT U.universityID, U.universityName 
         FROM UNIVERSITIES U 
         LEFT JOIN COSTS C ON U.universityID = C.universityID
         WHERE C.costID IS NULL;` 
    );
const costData = (rows && rows[0]) ? rows[0] : [];
    res.render('costs', {
      costs: costData,
      universities: universities[0],
    availableUniversities: availableUniversities,
	note: "Note: A new cost record can only be added if a cost record tied to a university does not already exist."});
  } catch (err) {
    console.error(err);
    res.render('costs', { error: 'Database error' });
  }
});

app.post('/costs/add', async function(req, res){
    const { universityID, fees, boarding, meals, books } = req.body;
    try {
        await db.query('CALL add_cost(?, ?, ?, ?, ?)', [universityID, fees, boarding, meals, books]);
        res.redirect('/costs');
    } catch (err) {
        console.error("Error adding cost record:", err);
        res.render('costs', { error: 'Failed to add new Cost Record' });
    }
});

app.post('/costs/update', async function(req, res){
    const { costID, fees, boarding, meals, books } = req.body;
    try {
        await db.query('CALL update_cost(?, ?, ?, ?, ?)', [costID, fees, boarding, meals, books]);
        await db.query('SELECT 1;');
        res.redirect('/costs');
    } catch (err) {
        console.error("Error updating cost record:", err);
        res.render('costs', { error: 'Failed to update Cost details' });
    }
});

app.post('/costs/remove', async function(req, res){
    const { costID } = req.body;
    try {
        await db.query('CALL remove_cost(?)', [costID]);
        await db.query('SELECT 1;');
        res.redirect('/costs');
    } catch (err) {
        console.error("Error deleting cost record:", err);
        res.render('costs', { error: 'Failed to delete Cost Record' });
    }
});

 
// Tuition page
app.get('/tuition', async function(req, res){
  try {
    const [rows] = await db.query('CALL select_cost_by_institution(?);',[null]);

    const [universities] = await db.query('CALL select_universities();');
    const [availableCosts] = await db.query(
        `SELECT C.costID, U.universityName
         FROM COSTS C 
         JOIN UNIVERSITIES U ON C.universityID = U.universityID
	 LEFT JOIN TUITION T ON C.costID = T.costID
	 WHERE T.costID IS NULL;`
    );

    res.render('tuition', {
      tuition: rows[0], 
      universities: universities[0], 
      costs: availableCosts,
note: "Note: A new tuition record can only be created if an existing tuition record tied to a cost record does not exist."
    });
  } catch (err) {
    console.error(err);
    res.render('tuition', { error: 'Database error' });
  }
});

// Tuition update route
app.post('/tuition/update', async function(req, res){
    const { inStateTuition, outOfStateTuition, tuitionID } = req.body; 
    
    try {
        await db.query('CALL update_tuition_by_id(?, ?, ?)', [
            tuitionID, 
            inStateTuition, 
            outOfStateTuition
        ]);
        
        await db.query('SELECT 1;'); 
        
        res.redirect('/tuition');
    } catch (err) {
        console.error("Error updating tuition:", err);
        res.render('tuition', { error: 'Failed to update tuition details.' });
    }
});
app.post('/tuition/add', async function(req, res){
    const { costID, inStateTuition, outOfStateTuition } = req.body;
    try {
        await db.query('CALL create_tuition_record(?, ?, ?)', [costID, inStateTuition, outOfStateTuition]);
        res.redirect('/tuition');
    } catch (err) {
        console.error("Error creating tuition record:", err);
        res.render('tuition', { error: 'Failed to add new Tuition Record. Record may already exist for this Cost ID.' });
    }
});
app.post('/tuition/remove', async function(req, res){
    const { tuitionID } = req.body; 
    try {
        await db.query('CALL remove_tuition(?)', [tuitionID]); 
        await db.query('COMMIT;');
        res.redirect('/tuition');
    } catch (err) {
        console.error(err);
        res.render('tuition', { error: 'Failed to delete Tuition Record' });
    }
});
// Universities-Has-Athletics page
app.get('/universities_has_athletics', async function(req, res){
  try {
    const [rows] = await db.query('CALL select_universities_has_athletics();');
    const [universities] = await db.query('CALL select_universities();');
    const [sports] = await db.query('CALL select_sports();');
    res.render('universities_has_athletics', { assignments: rows[0],universities: universities[0],sports: sports[0]});
  } catch (err) {
    console.error(err);
    res.render('universities_has_athletics', { error: 'Database error' });
  }
});

app.post('/universities_has_athletics/add', async function(req, res){
    const { universityID, sportID } = req.body;
    try {
        await db.query('CALL add_sport_to_institution(?, ?)', [universityID, sportID]);
        res.redirect('/universities_has_athletics');
    } catch (err) {
        console.error("Error adding assignment:", err);
        res.render('universities_has_athletics', { error: 'Failed to create assignment' });
    }
});
app.post('/universities_has_athletics/update', async function(req, res){
    const { universityID, originalSportID, sportID } = req.body;
    
    if (originalSportID === sportID) {
        return res.redirect('/universities_has_athletics');
    }

    try {
        await db.query('CALL update_sport_assignment(?, ?, ?)', [
            universityID,     
            originalSportID,  
            sportID          
        ]);
        
        res.redirect('/universities_has_athletics');
    } catch (err) {
        console.error(err);
        res.render('universities_has_athletics', { error: 'Failed to update assignment: Assignment already exists or IDs are invalid.' });
    }
});
app.post('/universities_has_athletics/remove', async function(req, res){
    const { universityID, sportID } = req.body;
    try {
        await db.query('CALL remove_sport_from_institution(?, ?)', [universityID, sportID]);
        res.redirect('/universities_has_athletics');
    } catch (err) {
        console.error("Error deleting assignment:", err);
        res.render('universities_has_athletics', { error: 'Failed to remove assignment' });
    }
});
// Universities-Has-Majors page
app.get('/universities_has_majors', async function(req, res){
  
  try {
    // majors assigned to the selected university
    const [assignments] = await db.query('CALL select_universities_has_majors();');

    // for dropdowns
    const [universities] = await db.query('CALL select_universities();');
    const [majors] = await db.query('CALL select_majors();');

    res.render('universities_has_majors', { 
      assignments: assignments[0],   // majors for selected university
      universities: universities[0], // dropdown option
      majors: majors[0],             // dropdown option
      
    });
  } catch (err) {
    console.error(err);
    res.render('universities_has_majors', { error: 'Database error' });
  }
});
app.post('/universities_has_majors/add', async function(req, res){
    const { universityID, majorID } = req.body;
    try {
        await db.query('CALL add_major_to_institution(?, ?)', [universityID, majorID]);
        res.redirect('/universities_has_majors');
    } catch (err) {
        console.error("Error adding assignment:", err);
        res.render('universities_has_majors', { error: 'Failed to create assignment' });
    }
});
app.post('/universities_has_majors/update', async function(req, res){
    const { universityID, originalMajorID, majorID } = req.body;
    
    if (originalMajorID === majorID) {
        return res.redirect('/universities_has_majors');
    }

    try {
        await db.query('CALL update_major_assignment(?, ?, ?)', [universityID, originalMajorID, majorID]);
        res.redirect('/universities_has_majors');
    } catch (err) {
        console.error("Error updating assignment:", err);
        res.render('universities_has_majors', { error: 'Failed to update assignment' });
    }
});
app.post('/universities_has_majors/remove', async function(req, res){
    const { universityID, majorID } = req.body;
    try {
        await db.query('CALL remove_major_from_institution(?, ?)', [universityID, majorID]);
        res.redirect('/universities_has_majors');
    } catch (err) {
        console.error("Error deleting assignment:", err);
        res.render('universities_has_majors', { error: 'Failed to remove assignment' });
    }
});


// ########################################
// ########## LISTENER

app.listen(PORT, function () {
    console.log(
        'Express started on http://classwork.engr.oregonstate.edu:' +
            PORT +
            '; press Ctrl-C to terminate.'
    );
    
  // listRoutes(app); // <-- Now runs after everything is set up

});
