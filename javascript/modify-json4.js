var json = '[{"{#HOSTNAME}":"first","{#HOSTGROUP}":"Linux servers"},{"{#HOSTNAME}":"second","{#HOSTGROUP}":"Windows servers"},{"{#HOSTNAME}":"third","{#HOSTGROUP}":"SNMP device"}]';

// take input and execute a replacement operation
// it is required because it is hard to locate and transorm JSON elements
// which is having a hashtag or curly parentheses
json = json
  .replace(/{#HOSTNAME}/gm, 'HOSTNAME')
  .replace(/{#HOSTGROUP}/gm, 'HOSTGROUP');

// convert text string native JSON object to use JavaScript native functions to work with JSON object
var JsonObject = JSON.parse(json);

// measure the lenght of array
lenghtOfArray = JsonObject.length;

// loop over the elements
for (var row = 0; row < lenghtOfArray; row++) {

  // extra condituions to modify a value if certain conditions match
  switch (JsonObject[row].HOSTNAME) {
    case "first":
      JsonObject[row].HOSTGROUP = 'kaste';
      break;
    case "second":
      JsonObject[row].HOSTGROUP = 'karba';
      break;
  }

}

return JSON.stringify(JsonObject)
  .replace(/HOSTNAME/gm, '{#HOSTNAME}')
  .replace(/HOSTGROUP/gm, '{#HOSTGROUP}');;
