app.config(['$routeProvider', function($routeProvider){
    $routeProvider
        .when('/', {
            templateUrl: "partials/index.hbs",
            controller: "homePageController"
        })
        .when('/dashboard', {
            templateUrl: "partials/dashboard.hbs",
            controller: "dashboardController"
        })
        .when('/signup', {
            templateUrl: "partials/signup.hbs",
            controller: "signUpController"
        })
        .when('/clientServices', {
            templateUrl: "partials/clientServices.hbs"
        })
}]);