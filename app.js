// DrawSQL – Node.js Templates

// DrawSQL. (n.d.). Node.js templates. DrawSQL. Retrieved November 4, 2025, 
// from https://drawsql.app/templates/tags/nodejs

// GeeksforGeeks – Student Management System Tutorial

// GeeksforGeeks. (2022, October 17). Node.js student management system
//  using Express.js and EJS templating engine. GeeksforGeeks. 
// Retrieved November 4, 2025, from https://www.geeksforgeeks.org/node-js-student-management-system-using-express-js-and-ejs-templating-engine/

// GitHub – Node.js Template Repositories

// GitHub. (n.d.). Node.js template repositories. GitHub Topics. 
// Retrieved November 4, 2025, from https://github.com/topics/nodejs-template


const express = require('express');
const app = express();
const db = require('./db-connector');
const bodyParser = require('body-parser');

app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static('public'));

const handlebars = require('express-handlebars').create({
  defaultLayout: 'main',
  extname: 'hbs'
});
app.engine('hbs', handlebars.engine);
app.set('view engine', 'hbs');
app.set('port', 14222);

// Route imports
app.use('/', require('./routes/universities'));
app.use('/', require('./routes/majors'));
app.use('/', require('./routes/athletics'));
app.use('/', require('./routes/costs'));
app.use('/', require('./routes/reset'));

app.listen(14222, () => {
  console.log('Server is running on port 14222');
});