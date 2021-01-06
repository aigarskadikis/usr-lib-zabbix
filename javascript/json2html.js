const json = '{"jsonrpc":"2.0","result":[{"name":"first","count":"3","id":"123"},{"name":"second","count":"0","id":"456"},{"name":"third","count":"12","id":"789"}]}';

// convert the json string to native JS Object
var JsonObject = JSON.parse(json);
var results = JsonObject.result;


// prepare an empty string
var htmlString = '';

// loop over the elements
for (var i = 0; i < results.length; i++) {
	var el = results[i];
	
	// skip it if count is 0
	if (el.count == '0') {
		continue;
	}
	// append the neccesary code at the end of the string.
	htmlString = htmlString.concat(
		'<a href="id=' +
			el.id +
			'">' +
			el.count +
			' elements detected at ' +
			el.name +
			'</a>'
	);

	// if it's not the last element then append the brake element
	if (i !== results.length - 1) {
		htmlString = htmlString.concat('<br/>');
	}
	
}

// here's your html String sir!
return htmlString;
