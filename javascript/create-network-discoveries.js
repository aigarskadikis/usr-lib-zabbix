// parse all input arguments
// var params = JSON.parse(value);

// define new HTTP request
var req = new CurlHttpRequest();

// where Zabbix API endpoint is located
var json_rpc='https://z60.aigarskadikis.com:44360/api_jsonrpc.php';

var apitoken='1ea44902a0bb98e95fb722d0b956fd373e755b48aa8e23dedf812d582594d1ca';

// this will be JSON call
req.AddHeader('Content-Type: application/json');

// close event based on event id and report the answer
var response = JSON.parse(req.Post(json_rpc,
'{"jsonrpc":"2.0","method":"drule.get","params":{"output":"extend","selectDChecks":"extend"},"auth":"'+apitoken+'","id":1}'
));

return JSON.stringify(response);

