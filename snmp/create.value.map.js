// zabbix_js -s create.value.map.js -p '{"name":"kasteee","mappings":"{\"newvalue\":\"enabled\",\"value\":\"1\"},{\"newvalue\":\"disabled\",\"value\":\"2\"}","api_jsonrpc":"http://127.0.0.1/api_jsonrpc.php","sid":"64659f1aaf07b61a1bac86a4385435ba"}'

var params = JSON.parse(value);

var req = new CurlHttpRequest();

var json_rpc=params.api_jsonrpc;

req.AddHeader('Content-Type: application/json');

// check if value map already exists
var output = JSON.parse(req.Post(json_rpc,
'{"jsonrpc":"2.0","method":"valuemap.get","params":{"filter":{"name":"'+params.name+'"},"output":["valuemapid"]},"auth":"'+params.sid+'","id":1}'
));
// Zabbix.Log(3,JSON.stringify(output));

// if value map do not exist, then create new
if ( output.result.length == 0 ) {
var output = JSON.parse(req.Post(json_rpc,
'{"jsonrpc":"2.0","method":"valuemap.create","params":{"name":"'+params.name+'","mappings":['+params.mappings+']},"auth":"'+params.sid+'","id":1}'
));
} else {
// return result which was already there
return JSON.stringify(output.result[0].valuemapid).match(/([0-9]+)/)[1]
}
// return new id
return JSON.stringify(output.result.valuemapids[0]).match(/([0-9]+)/)[1];


