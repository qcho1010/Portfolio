var mysql = require("mysql");

exports.updateResourceConnection = function(data, next) {
    var connection = mysql.createConnection({
        host: "Globalhack.il1.rdbs.ctl.io",
        port: "49424",
        user: "GHack",
        password: "GlobalHack123!",
        database: "globalhack"
    });

    var result;

    connection.connect();

    console.log("in update");
    var Type = connection.escape(data.Type);
    var Description = connection.escape(data.Description);
    var NumTotal = connection.escape(data.NumTotal);
    var NumUsed = connection.escape(data.NumUsed);

    var values = [Type, Description, NumTotal, NumUsed];

    connection.query('insert into Resources (Facility, Type, Description, NumTotal, NumUsed) values (' + values + ') on duplicate key update Facility = ' + Facility + ', Type = ' + Type + ', Description = ' + Description + ', NumTotal = ' + NumTotal + ', NumUsed = ' + NumUsed , function (err, rows) {
        console.log(err);
        if (err) next(400);
        else {
            result = 200;
            connection.end();
            next(result);
        }
    })
};