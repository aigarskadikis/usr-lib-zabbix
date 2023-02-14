// works with zabbix_js 6.2.3
var params=JSON.parse(value);
var request = new HttpRequest();
if (params.proxy) {
request.setProxy(params.proxy);
}
return request.get('https://www.zabbix.com/robots.txt');

