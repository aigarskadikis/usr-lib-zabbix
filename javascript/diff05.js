var arr1 = [ 2, 3, 5 ];
var arr2 = [ 1, 4, 5, 6 ];

// merge, remove dublicates, sort
var arr3 = arr1.concat(arr2)
	.reduce(function(a,b) { if(a.indexOf(b) < 0) a.push(b); return a; },[])
	.sort(function(a, b){return a - b});

// detect processes which has gone away. compare second array with arr3

var gone = [];
var news = [];

// measure length of first array
var length_first=arr1.length;

// measure length of second array
var length_second=arr2.length;

// total
var length_max=arr3.length;


// array elements starts from index:0
var pointer1=0;
var pointer2=0;

var sum=0;
// start to go through elements
while ( pointer1 < length_second-1 && pointer2 < length_max-1 ) {

// if both integers are equeal then skip
if ( arr2[pointer1] == arr3[pointer2] ) {
	// if this is NOT yet end of array1 then increase pointer
	if ( pointer1 < length_second-1 ) pointer1++;
	// if this is NOT end of array2 then increase pointer
	if ( pointer2 < length_max-1 ) pointer2++;
}

// if first element is smaller than second, it means the process has gone away
// navigate to next process
if ( arr2[pointer1] > arr3[pointer2] ) {
        gone.push(arr3[pointer2]); pointer2++;
} else { pointer1++; }

}

var pointer1=0;
var pointer2=0;

while ( pointer1 < length_first-1 && pointer2 < length_max-1 ) {

// if both integers are equeal then skip
if ( arr1[pointer1] == arr3[pointer2] ) {
        // if this is NOT yet end of array1 then increase pointer
        if ( pointer1 < length_first-1 ) pointer1++;
        // if this is NOT end of array2 then increase pointer
        if ( pointer2 < length_max-1 ) pointer2++;
}

// if first element is smaller than second, it means the process has news away
// navigate to next process
if ( arr1[pointer1] > arr3[pointer2] ) {
        news.push(arr3[pointer2]); pointer2++;
} else { pointer1++; }

}

return 'new:'+news+' \ngone:'+gone;

