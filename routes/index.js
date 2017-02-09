var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('landingPage', { title: 'Express' });
});

/*GET create account. */

router.get('/createaccount', function (req, res, next) {
	res.render('createAccount', {title: 'Success'});
});

module.exports = router;
