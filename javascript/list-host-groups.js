var req = new CurlHttpRequest();

// Zabbix API
var json_rpc='http://167.71.78.40/api_jsonrpc.php'

// lib curl header
req.AddHeader('Content-Type: application/json');

// first request to obtain authorization tokken of Zabbix API
var token =  JSON.parse(req.Post(json_rpc,
'{"jsonrpc":"2.0","method":"user.login","params":{"user":"api","password":"zabbix"},"id":1,"auth":null}'
)).result;

// get the global macro ID
// we cannot plot here a very native Zabbix macro because it will be automatically expanded
// must use a workaround to distinguish a dollar sign from the actual macro name like and merge together with '+'
var hostid = JSON.parse(req.Post(json_rpc,
'{"jsonrpc":"2.0","method":"host.get","params":{"output":["hostid"],"filter":{"host":["'+value+'"]}},"auth":"'+token+'","id":1}'
)).result[0].hostid;

var hostgroups = JSON.parse(req.Post(json_rpc,
'{"jsonrpc":"2.0","method":"hostgroup.get","params":{"output":"extend","hostids":['+hostid+']},"auth":"'+token+'","id":1}'
)).result;

// start a loop to go through array elements
var lenghtOfArray=hostgroups.length;

var allHostGroupsCSV = "";

for(var row = 0; row < lenghtOfArray; row++){
allHostGroupsCSV += hostgroups[row].name + ",";
}

// Delete last comma at the end
allHostGroupsCSV = allHostGroupsCSV.replace(/,$/,"");


// close the session token
var logout = JSON.parse(req.Post(json_rpc,
'{"jsonrpc":"2.0","method":"user.logout","params":[],"id":1,"auth":"'+token+'"}'
));

//return JSON.stringify(hostgroups);
//return hostgroups;
//return lenghtOfArray;
return allHostGroupsCSV;

