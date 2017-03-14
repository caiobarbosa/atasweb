angular.module("app", ['frapontillo.gage'])
  .factory('dataFactory', function($http) {
    return {
      list: function() {
        return $http.get('/admeasurements/list/' + angular.element(document.querySelector('#user_id')).html()).success(function(data, status){
          return data.pressures;
        });
      }
    }
  })
  .filter('sensorKind', function() {
    return function(x) {
      var txt = "";
      if(x == 0) {
        txt = "Ambiente";
      }else{
        txt = "Refrigerador";
      }

      return txt;
    };
  })
  .filter('capacityCylinder', function() {
    return function(input) {
      var capacity = 0;
      if(input == "5L" || input == "4L") {
        capacity = 150;
      }else{
        capacity = 200;
      }

      return capacity;
    };
  })

  .factory('temperatureDataFactory', function($http) {
    return {
      list: function() {
        return $http.get('/admeasurements/list_temperatures/' + angular.element(document.querySelector('#user_id')).html()).success(function(data, status){
          return data.temperature_sensors;
        });
      }
    }
  })

  .controller("LineCtrl", function ($scope, $rootScope, dataFactory) {
    $rootScope.gageColors = ["#ff0000", "#f9c802", "#a9d70b"];
    $rootScope.gageSectors = [{
      color : "#ff0000",
      lo : 0,
      hi : 66.999999
    },{
      color : "#f9c802",
      lo : 67,
      hi : 133.999999
    },{
      color : "#a9d70b",
      lo : 134,
      hi : 200
    }];

    dataFactory.list().success(function(data) {
      $scope.sensors = data.pressures.map(function(sensor) { sensor.value = 0, sensor.spent = 0; return sensor } );
    });

    PrivatePub.subscribe("/pressures/"+ angular.element(document.querySelector('#user_id')).html() + "/new", function(data, channel) {
      $scope.$apply(function($scope) {
        //var result = $.grep($scope.sensors, function(e){ return e.id == data.pressure.sensor.id; });
        var result = $scope.sensors.filter(function(e){ return e.id == data.pressure.sensor.id; });

        if (result.length > 0) {
          result[0].name = data.pressure.sensor.name;
          result[0].capacity = data.pressure.sensor.capacity;
          result[0].value = (new Number(data.pressure.pressure.value)).toFixed();
          result[0].spent = (new Number(data.pressure.pressure.spent));
          result[0].estimate = data.pressure.pressure.estimate;
        } else {
          $scope.sensors.push(
            {
              id: data.pressure.sensor.id,
              capacity: data.pressure.sensor.capacity,
              name: data.pressure.sensor.name,
              value: data.pressure.pressure.value,
              spent: data.pressure.pressure.spent,
              estimate: data.pressure.pressure.estimate
            }
          );
        };

      });
    });

  })

.controller("TemperatureSensorsCtrl", function ($scope, temperatureDataFactory) {

    temperatureDataFactory.list().success(function(data) {
      $scope.sensors = data.temperature_sensors.map(function(sensor) { sensor.value = 0, sensor.humidity = 0, sensor.status_door = null ; return sensor } );
    });

    PrivatePub.subscribe("/temperatures/"+ angular.element(document.querySelector('#user_id')).html() + "/new", function(data, channel) {
      $scope.$apply(function($scope) {
        var result = $scope.sensors.filter(function(e){ return e.id == data.temperature.sensor.id; });

        if (result.length > 0) {
          result[0].name = data.temperature.sensor.name;
          result[0].value = data.temperature.temperature.value;
          result[0].humidity = data.temperature.temperature.humidity;
          result[0].status_door = data.temperature.temperature.status_door;
        } else {
          $scope.sensors.push(
            {
              id: data.temperature.sensor.id,
              name: data.temperature.sensor.name,
              value: data.temperature.temperature.value,
              humidity: data.temperature.temperature.humidity,
              status_door: data.temperature.temperature.status_door
            }
          );
        };

      });
    });

});

