var request = new HttpRequest();
var res = request.get(value);
var head = request.getHeaders(true);
return JSON.stringify(head);
