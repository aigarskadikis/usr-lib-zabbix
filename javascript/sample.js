var req = new CurlHttpRequest();
var resp = req.Get('https://'+value+'.blogspot.com/robots.txt');
return resp;

