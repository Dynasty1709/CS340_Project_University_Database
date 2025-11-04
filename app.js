/*
    SETUP
*/
var express = require('express');
var app = express();

// Handlebars
// Handlebars
var handlebars = require('express-handlebars').create({
    defaultLayout:'main',
    extname: 'hbs' // <-- Tells Handlebars to look for .hbs files
});
app.engine('hbs', handlebars.engine); // <-- Registers the engine as 'hbs'
app.set('view engine', 'hbs'); // <-- Tells Express to use the 'hbs' engine

// Port
app.set('port', 9124); // Your port number

// Static Files (for CSS)
app.use(express.static('public'));

/*
    ROUTES
*/
// This is your first page (the index)
app.get('/', function(req, res){
    res.render('index');
});
/*
    ROUTES
*/
// 1. Index Page
app.get('/', function(req, res){
    res.render('index');
});

// 2. Universities Page
app.get('/universities', function(req, res){
    res.render('universities');
});
// 3. Athletics Page
app.get('/athletics', function(req, res){
    res.render('athletics');
});

// 4. Majors Page
app.get('/majors', function(req, res){
    res.render('majors');
});

// 5. Costs Page
app.get('/costs', function(req, res){
    res.render('costs');
});

// 6. Tuition Page
app.get('/tuition', function(req, res){
    res.render('tuition');
});

// 7. University-Athletics Page (M:N)
app.get('/universities_has_athletics', function(req, res){
    res.render('universities_has_athletics');
});

// 8. University-Majors Page (M:N)
app.get('/universities_has_majors', function(req, res){
    res.render('universities_has_majors');
});
/*
    LISTENER
*/
app.listen(app.get('port'), function(){
    console.log('Express started on http://localhost:' + app.get('port') + '; press Ctrl-C to terminate.');
});