var arr1 = [ 2, 3, 5 ];
var arr2 = [ 1, 4, 5, 6 ];

// merge, remove dublicates, sort
var arr3 = arr1.concat(arr2)
	.reduce(function(a,b) { if(a.indexOf(b) < 0) a.push(b); return a; },[])
	.sort(function(a, b){return a - b});

var news = []; var gone = [];

function arr_diff (a1, a2) {

    var a = [], diff = [];

    for (var i = 0; i < a1.length; i++) {
        a[a1[i]] = true;
    }

    for (var i = 0; i < a2.length; i++) {
        if (a[a2[i]]) {
            delete a[a2[i]];
        } else {
            a[a2[i]] = true;
        }
    }

    for (var k in a) {
        diff.push(k);
    }

    return diff;
}

news=arr_diff(arr3,arr1);
gone=arr_diff(arr3,arr2);

return '      arr1: '+arr1+'\n      arr2: '+arr2+'\n    merged: '+arr3+'\nnew values: '+news+' \n gone away: '+gone;

