var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('user');
});

router.post('/dashboard', function (req, res) {
    res.send({title: "Good"});
    // res.redirect('/#/dashboard');
});

var providerSubmitter = require('./signUpDatabaseConnector');
router.post('/submitNewProvider', function (req, res) {
    providerSubmitter.signUpNewProvider(req.body, function (result) {
        console.log("Submit new provider");
        res.send({code: 200});
        // res.send(result);
    })
});

var dashboardUpdater = require("./dashboardUpdate");
router.post('/updateResources', function(req, res) {
    dashboardUpdater.updateResourceConnection(req.body, function (result) {
        console.log("update resources");
        res.send(result);
    });
});
var databaseConnector = require("./dashboardDatabasConnector");
router.get('/facilities', function (req, res, next) {
    databaseConnector.getDataForDashboard(function (result) {
        res.send(result);
    });
});

module.exports = router;
