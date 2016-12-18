var mysql = require("mysql");

exports.getDataForDashboard = function (next) {
    var connection = mysql.createConnection({
        host: "Globalhack.il1.rdbs.ctl.io",
        port: "49424",
        user: "GHack",
        password: "GlobalHack123!",
        database: "globalhack"
    });

    var result = {};
    //$scope.res = {Facility: '', Type: '', Description: '',
      //  NumTotal: '', NumUsed: ''};

    connection.connect();


    connection.query("Select Type, Description, NumTotal, NumUsed from Resources where Facility=6",
        function (err, rows) {
        if (err) console.log("Bad connection");
        console.log("Good connection");
        for(var i = 0; i < rows.length; i++) {
            result[i] = rows[i];
        }
         console.log(result);
        connection.end();
        next(result);
    });

   /* connection.query("select Name from globalhack.Resources where ID=6", function (err, rows) {
        if (err) console.log("Bad connection");
        console.log("good connection");
        org = rows[i];
        connection.end();
        next(result);
    });*/
};