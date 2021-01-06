var json = '{"jsonrpc":"2.0","result":[{"{#HOSTNAME}":"first","{#HOSTGROUP}":"Linux servers"},{"{#HOSTNAME}":"second","{#HOSTGROUP}":"Windows servers"},{"{#HOSTNAME}":"third","{#HOSTGROUP}":"SNMP device"}]}';

json = json
.replace(/{#HOSTNAME}/gm,'HOSTNAME')
.replace(/{#HOSTGROUP}/gm,'HOSTGROUP');

// convert the json string to native JS Object
var JsonObject = JSON.parse(json);
var results = JsonObject.result;


// lenght of array
lenghtOfArray=results.length;

// loop over the elements
for(var row = 0; row < lenghtOfArray; row++) {

if (results[row].HOSTNAME == 'first') results[row].HOSTGROUP='kaste';
	
}

return JSON.stringify(results)
.replace(/HOSTNAME/gm,'{#HOSTNAME}')
.replace(/HOSTGROUP/gm,'{#HOSTGROUP}');
;
