app.controller('signUpController', ['$scope', '$http', function ($scope, $http) {

    $scope.submitSignUpInfo = function () {
        console.log("submitSignUpInfo");

        var data ={
            name: "Bills Barbershop",
            phnumber: "3145887788",
            email: "bbshopgmailcom",
            info: "I want to provide free haircuts"
        };

        var config = {
            headers : {
                'Content-Type': 'application/json;'
            }
        };

        $http({
            url: "/submitNewProvider",
            method: "POST",
            data: data,
            headers: config

        })
            .then(function (response) {
                if(response.status == 200) {
                    alert("Thank you! We received your application!");
                }
                else {
                    alert("We are sorry. Please submit again.");
                }
            });

    }

}]);