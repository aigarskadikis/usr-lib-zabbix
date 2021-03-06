
var req = new CurlHttpRequest();

var lld = [];
var url = "";
var resp = "";

// loop starts
var step = 0;
var is_content = 1;

do {

step++;

// define url to fetch
url = "https://"+value+"/feeds/posts/default/?atom.xml?redirect=false&start-index="+step+"&max-results=1"

// clear variable
var resp = "";

// download page
resp = req.Get(url);

is_content = resp.match(/<\/content>/) ? 1 : 0;

// check if there is content
while (is_content) {

// define an empty row
var row = {};

// blog name
row["{#BLOGNAME}"] = value;

// blog identification
row["{#BLOGID}"] = resp.match(/blog-([0-9]+)\.post-[0-9]+/)[1];

// post identification
row["{#POSTID}"] = resp.match(/blog-[0-9]+\.post-([0-9]+)/)[1];

// extract title
row["{#TITLE}"] = resp.match(/html..title=.(.*).\/><author>/)[1];

// lookup URL
row["{#URL}"] = resp.match(/(https[a-zA-Z0-9_\-\.\/:]+\.html)/)[0];

// add this to array
lld.push(row);

break;

}
// end of content check

}
while (is_content)


return JSON.stringify(lld);
