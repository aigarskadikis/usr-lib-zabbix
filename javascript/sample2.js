// define new HTTP request
var req = new CurlHttpRequest();

// where Zabbix API endpoint is located
var json_rpc='http://158.101.218.248:154/api_jsonrpc.php';

// this will be JSON call
req.AddHeader('Content-Type: application/json');

// close event based on event id and report the answer
var response = JSON.parse(req.Post(json_rpc,
'{"jsonrpc":"2.0","method":"proxy.get","params":{"output":["name"]},"auth":"'+value+'","id":1}'
));

return JSON.stringify(response);
