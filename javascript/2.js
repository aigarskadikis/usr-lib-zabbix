// parse all input arguments
// var params = JSON.parse(value);

// define new HTTP request
var req = new CurlHttpRequest();

// where Zabbix API endpoint is located
var json_rpc='http://10.133.253.43:154/api_jsonrpc.php';

// this will be JSON call
req.AddHeader('Content-Type: application/json');

// close event based on event id and report the answer
var response = JSON.parse(req.Post(json_rpc,
'{"jsonrpc":"2.0","method":"event.acknowledge","params":{"eventids":"'+value+'","action":1,"message":"Problemresolved."},"auth":"53618d89a6d9d892f2b1c7baa393d2b2afb46238f8e8ca2cdbc84e0ae0be72ef","id":1}'
));

return JSON.stringify(response);

