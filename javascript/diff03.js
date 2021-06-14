var arr1 = [ 1, 2, 3, 5 ];
var arr2 = [ 1, 4, 5, 6 ];
// merge, remove dublicates, sort
var arr3 = arr1.concat(arr2)
	.reduce(function(a,b){if(a.indexOf(b) < 0)a.push(b);return a;},[])
	.sort(function(a, b){return a - b});





return arr3;

