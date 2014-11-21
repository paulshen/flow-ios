
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

var Transaction = Parse.Object.extend('Transaction');
Parse.Cloud.define("totalspend", function(req, res) {
  var query = new Parse.Query(Transaction);
  query.limit(1000);
  query.find({
    success: function(results) {
      var sum = 0;
      results.forEach(function(result) {
        sum += result.get('amount');
      });
      res.success(sum);
    }
  });
});

Parse.Cloud.define("dashboarddata", function(req, res) {
  var query = new Parse.Query(Transaction);
  var today = new Date();
  var threeMonthsAgo = new Date(Date.UTC(today.getFullYear(), today.getUTCMonth() - 2));
  query.greaterThanOrEqualTo('date', threeMonthsAgo);
  query.limit(1000);
  query.find({
    success: function(results) {
      var data = {};
      results.forEach(function(result) {
        var date = result.get('date');
        var year = date.getUTCFullYear();
        var month = date.getUTCMonth();
        if (!data[year]) {
          data[year] = {};
        }
        if (typeof data[year][month] === 'undefined') {
          data[year][month] = 0;
        }
        data[year][month] += result.get('amount');
      });
      for (var year in data) {
        for (var month in data[year]) {
          data[year][month] = Math.round(data[year][month] * 100) / 100;
        }
      }
      res.success(data);
    }
  });
});
