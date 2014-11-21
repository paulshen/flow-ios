
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

var Transaction = Parse.Object.extend('Transaction');
Parse.Cloud.define("totalspend", function(req, res) {
  var query = new Parse.Query(Transaction);
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
