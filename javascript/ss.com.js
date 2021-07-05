// new curl request
var req = new CurlHttpRequest();

// open a new array. this will be JSON array
var lld = [];

// clear up URL
var url = "";

// this will be main loop. it will go as long as the page has good content
var step = 0;

// start the page checking one by one for example
// https://www.ss.com/lv/electronics/computers/game-consoles/page1.html
// https://www.ss.com/lv/electronics/computers/game-consoles/page2.html
// https://www.ss.com/lv/electronics/computers/game-consoles/page3.html
// ... and so on ...

// define a flag which will detect when there is no more data to check
var endOfList = 0;

// infinite loop starts
do {

// when this goes for the first time, it will start from page1
step++;

// start from page1
url = "https://www.ss.com/lv/electronics/computers/game-consoles/sell/page"+step+".html"
// the loop will end when the "Next" button goes to first page

// print URL on screen
// Zabbix.Log(3,url);

// clear variable
var resp = "";

// download page
resp = req.Get(url);

// print URL on screen only on debug level 4
// Zabbix.Log(4,resp);

// if there is some content on page the examine links
if (!endOfList) {
// extract all child elements and remove dublicates
var msgs = resp.match(/(\/msg[a-zA-Z0-9_\-\.\/:]+\.html)/gm)
.reduce(function(a,b){if(a.indexOf(b)< 0)a.push(b);return a;},[]);

// how many elements are on page. an element is an anchor which contains href="/msg/someting/..."
elements = msgs.length;

// print count of elements to log
// Zabbix.Log(3,elements);

// go tgrough loop to feed JSON array
for (i = 0; i < elements; i++) {

// define an empty row. this is required for JSON
var row = {};

// extract Nth element and put it on URL
row["{#URL}"] = 'https://www.ss.com'+msgs[i];

var single = req.Get(row["{#URL}"]);
row["{#PRICE}"] = single.match(/MSG_PRICE = ([0-9\.]+)/)[1];
Zabbix.Log(3,row["{#PRICE}"]);

// type
row["{#TYPE}"] = single.match(/tdo_1649..nowrap.([a-zA-Z0-9 ]+)/)[1];
Zabbix.Log(3,row["{#TYPE}"]);

// add this to array
lld.push(row);

}

// practically in goes untill the "Next" button on the last page does not work (it redirects to page1)
endOfList = resp.match(/game.consoles.sell...N.kamie/gm) ? 1 : 0;

}

} while (!endOfList)

return JSON.stringify(lld);
