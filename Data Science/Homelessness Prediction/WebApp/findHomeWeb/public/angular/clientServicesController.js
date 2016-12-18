app.controller('homePageController', ['$scope' , '$http', '$location', function ($scope, $http, $location) {
    $scope.message = "Got to the home page!";

    $scope.signup = function () {
        $location.path("/signup");
    };

    $scope.goToSignUpPage = function () {
        var config = {
            headers : {
                'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8;'
            }
        };
        console.log("Button Clicked");
        //$location.path("/signup");
        $http.post('/dashboard', $scope.message, config)
            .then(function (response) {
                $scope.message = response.data.title;
                console.log($scope.message);
                $location.path("/dashboard");
            })
    };


}]);