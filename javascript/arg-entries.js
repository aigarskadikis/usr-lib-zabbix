
var req = new CurlHttpRequest();

var lld = [];
var url = "";
var resp = "";

// loop starts
for (var step = 1; step < 501; step++) {

// define an empty roe
var row = {};

// define url to fetch
url = "https://"+value+".blogspot.com/feeds/posts/default/?atom.xml?redirect=false&start-index="+step+"&max-results=1"

var resp = "";

// fetch data. multiple variables will be fed later
resp = req.Get(url);

// blog identification
row["{#BLOG}"] = resp.match(/blog-([0-9]+)\.post-[0-9]+/)[1];

// post identification
row["{#POST}"] = resp.match(/blog-[0-9]+\.post-([0-9]+)/)[1];

// extract title
row["{#TITLE}"] = resp.match(/html..title=.(.*).\/><author>/)[1];

// lookup URL
row["{#URL}"] = resp.match(/(https[a-zA-Z0-9_\-\.\/:]+\.html)/)[0];

// detect if there is any category assigned to post. if none then report an empty array
row["{#CATS}"] = resp.match(/([0-9]<\/updated><category scheme.*www.blogger.com.*><title)/) ?
resp.match(/([0-9]<\/updated><category scheme.*www.blogger.com.*><title)/)[0]
.replace(/>/g,">\n")
.replace(/term=/gm,'\nterm=')
.match(/term=.([\w\s]+)/gm)
.join("\n")
.replace(/term=\"/gm,"\n")
.match(/^[a-zA-Z0-9 ]+/gm)
: [];

// add this to array
lld.push(row);

}

return JSON.stringify(lld);
