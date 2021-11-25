var req = new CurlHttpRequest();

// Zabbix API
var json_rpc='http://167.71.78.40/api_jsonrpc.php'

// lib curl header
req.AddHeader('Content-Type: application/json');

// first request to obtain authorization tokken of Zabbix API
var token =  JSON.parse(req.Post(json_rpc,
'{"jsonrpc":"2.0","method":"user.login","params":{"user":"api","password":"zabbix"},"id":1,"auth":null}'
)).result;

// create host group with name 'New Host Group'
var result = JSON.parse(req.Post(json_rpc,
'{"jsonrpc":"2.0","method":"hostgroup.create","params":{"name":"New Host Group"},"auth":"'+token+'","id":1}'
));

// close the session token
var logout = JSON.parse(req.Post(json_rpc,
'{"jsonrpc":"2.0","method":"user.logout","params":[],"id":1,"auth":"'+token+'"}'
));

// API resonse;
return JSON.stringify(result);

