var json = '[{"{#VM.NAME}":"first","{#DATACENTER.NAME}":"Linux servers"},{"{#VM.NAME}":"second","{#DATACENTER.NAME}":"Windows servers"},{"{#VM.NAME}":"third","{#DATACENTER.NAME}":"SNMP device"}]';

// convert text string native JSON object to use JavaScript native functions to work with JSON object
var JsonObject = JSON.parse(json);

// measure the lenght of array
lenghtOfArray = JsonObject.length;

// loop over the elements
for (var row = 0; row < lenghtOfArray; row++) {

  // extra condituions to modify a value if certain conditions match
  switch (JsonObject[row]["{#VM.NAME}"]) {
    case "sql":
    case "anotherNameOfVM":
    case "first":
      JsonObject[row]["{#DATACENTER.NAME}"] = 'dataCenterX';
      break;
    case "second":
      JsonObject[row]["{#DATACENTER.NAME}"] = 'karba';
      break;
  }

}

return JSON.stringify(JsonObject);
