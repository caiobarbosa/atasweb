/*global window:false, angular:false, Gauge:false*/
/**
 * angular-gaugejs version 0.1
 * License: MIT.
 * Copyright (C) 2014, Rasmus Schlünsen
 */

(function(angular) {
    'use strict';

    angular.module('gaugejs', [])
    .directive('gaugejs', [function() {
        return {
            restrict: 'AC',
            scope: {
                'animationTime': '=',
                'value': '=',
                'options': '=',
                'maxValue': '=',
                'gaugeType': '='
            },
            controller: function($scope, $element) {
                if ($scope.gaugeType === 'donut') {
                    $scope.gauge = new Donut($element[0]);
                } else {
                    $scope.gauge = new Gauge($element[0]);
                }

                $scope.gauge.maxValue = $scope.maxValue;
                $scope.gauge.setOptions($scope.options);

                $scope.$watch('value', function(value) {
                    if (!isNaN(value)){
                        $scope.gauge.set(
                            (value > $scope.maxValue) ? $scope.maxValue : value
                        );
                    }
                });
            },
        };
    }]);

})(window.angular);