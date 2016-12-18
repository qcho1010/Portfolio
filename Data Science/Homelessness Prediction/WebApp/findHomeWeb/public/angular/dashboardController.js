app.controller('dashboardController', ['$scope', '$http', '$location', function ($scope, $http, $location) {

    $scope.org;
    $scope.resourceName;
    $scope.description;
    $scope.qtyAvail;
    $scope.qtyTotal;

    var config = {
        headers : {
            'Content-Type': 'application/json;'
        }
    };

    $scope.updateData = function (results) {
        console.log("so far so good");
        $http({
            url: '/updateResources',
            method: "POST",
            data: results,
            options: {headers: {'Content-Type': 'application/json;'}}
        }).then(function() {
            getData();
        })
    };

    var getData = function () {
        $http.get('/facilities', config).then(function (result) {
            $scope.results = result.data;
            //console.log($scope.results);
        })
    };

    $scope.clientService = function () {
        $location.path("/clientServices");
    };

    getData();

  //  $scope.resourceList = {};

}]);