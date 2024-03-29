
// convert lines into array
var lines = value.split("\n");

// define new HTTP request
var req = new CurlHttpRequest();

// this will be JSON call
req.AddHeader('Content-Type: application/json');

// where Zabbix API endpoint is located
var json_rpc='https://z60.aigarskadikis.com:44360/api_jsonrpc.php';

var apitoken='1ea44902a0bb98e95fb722d0b956fd373e755b48aa8e23dedf812d582594d1ca';

var proxy_hostid=10597;

var delay='1m';
var response='';
var code='codename';

// iterate through file/array
for(var l = 0; l < lines.length-1; l++) {

// pick up name of profile
var name=lines[l].replace(/^[0-9]+ /,'').match(/.*/)[0];
// ip range
var subnet=lines[l].replace(/ .*$/,'');
var iprange='192.'+subnet+'.1.1-255';

// get all existing discovery rules
var existingDiscoveryRules = JSON.parse(req.Post(json_rpc,
'{"jsonrpc":"2.0","method":"drule.get","params":{"output":"extend","selectDChecks":"extend"},"auth":"'+apitoken+'","id":1}'
)).result;


var create=0;
// iterate through all existing and check if name exists
for(var r = 0; r < existingDiscoveryRules.length; r++) {
if ( name == existingDiscoveryRules[r].name ) {
	Zabbix.Log(3,'rule \"'+name+'\" exists');
	var create=0; break
} else { var create=1; }
}

Zabbix.Log(3,'create='+create);


// close event based on event id and report the answer
if (create==1) {
response = JSON.parse(req.Post(json_rpc,
'{"jsonrpc":"2.0","method":"drule.create","params":{"name":"'+code+' '+subnet+' '+name+'","delay": "'+delay+'","proxy_hostid": "'+proxy_hostid+'","iprange":"'+iprange+'","dchecks":[{"type":"13","key_":"1.3.6.1.2.1.1.2.0","snmp_community":"","ports":"161","snmpv3_securityname":"{$SNMP:user}","snmpv3_securitylevel":"2","snmpv3_authpassphrase":"{$SNMP:sha}","snmpv3_privpassphrase":"{$SNMP:aes}","uniq":"0","snmpv3_authprotocol":"1","snmpv3_privprotocol":"1","snmpv3_contextname":"","host_source":"2","name_source":"0"},{"type":"13","key_":"1.3.6.1.2.1.1.5.0","snmp_community":"","ports":"161","snmpv3_securityname":"{$SNMP:user}","snmpv3_securitylevel":"2","snmpv3_authpassphrase":"{$SNMP:sha}","snmpv3_privpassphrase":"{$SNMP:aes}","uniq":"0","snmpv3_authprotocol":"1","snmpv3_privprotocol":"1","snmpv3_contextname":"","host_source":"2","name_source":"3"},{"type":"13","key_":"1.3.6.1.2.1.1.1.0","snmp_community":"","ports":"161","snmpv3_securityname":"{$SNMP:user}","snmpv3_securitylevel":"2","snmpv3_authpassphrase":"{$SNMP:sha}","snmpv3_privpassphrase":"{$SNMP:aes}","uniq":"0","snmpv3_authprotocol":"1","snmpv3_privprotocol":"1","snmpv3_contextname":"","host_source":"2","name_source":"0"}]},"auth":"'+apitoken+'","id":1}'
));
} else { response='[]'; }

Zabbix.Log(3,JSON.stringify(response));

}

return 0;

