var first = [ 1, 2, 3, 5 ];
var second = [ 1, 4, 5, 6 ];
var gone = [];
var news = [];

// measure length of first array
var length_first=first.length;

// measure length of second array
var length_second=second.length;

// array elements starts from index:0
var pointer1=0;
var pointer2=0;


var sum=0;
// start to go through elements
while ( pointer1 < length_first && pointer2 < length_second ) {

// if both integers are equeal then skip
if ( first[pointer1] == second[pointer2] ) {
	// if this is NOT yet end of array1 then increase pointer
	if ( pointer1 < length_first-1 ) pointer1++;
	// if this is NOT end of array2 then increase pointer
	if ( pointer2 < length_second-1 ) pointer2++;
}

// if first element is smaller than second, it means something is iff
// let's investigate
// indicate the process as gone. increase go to next one
if ( first[pointer1] < second[pointer2] ) { 
	
	gone.push(first[pointer1]); pointer1++; 
}


}


return sum;
//return first.filter(x => second.indexOf(x) === -1);

