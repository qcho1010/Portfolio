app.controller('homePageController', ['$scope' , '$http', '$location', function ($scope, $http, $location) {
    $scope.message = "Got to the home page!";

    $scope.signUp = function () {
        $location.path("/signup");
    };

    $scope.signIn = function () {
        var config = {
            headers : {
                'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8;'
            }
        };
        console.log("Button Clicked");
        $http.post('/dashboard', $scope.message, config)
            .then(function (response) {
                $scope.message = response.data.title;
                console.log($scope.message);
                $location.path("/dashboard");
            })
    };
}]);