# Script to take entries of the form
# aap@hanauma	Amy Pang   	Mon Jan 27 1992
# aaw@awolf	aron wolf   	Tue Feb 4 1992
# then delete all but the latest entry for a given address.
# Entries already sorted on address.
# Invoke as awk -f thisfile thisyear=1992 infile
# @(#)sortdate.awk	1.1 2/5/92
BEGIN { 
    # Note: variables set on commandline are not valid in BEGIN!
    FS="\t";
    mon["JAN"]=1; mon["jan"] = 1; mon["Jan"]=1;
    mon["FEB"]=2; mon["feb"] = 2; mon["Feb"]=2;
    mon["MAR"]=3; mon["mar"] = 3; mon["Mar"]=3;
    mon["APR"]=4; mon["apr"] = 4; mon["Apr"]=4;
    mon["MAY"]=5; mon["may"] = 5; mon["May"]=5;
    mon["JUN"]=6; mon["jun"] = 6; mon["Jun"]=6;
    mon["JUL"]=7; mon["jul"] = 7; mon["Jul"]=7;
    mon["AUG"]=8; mon["aug"] = 8; mon["Aug"]=8;
    mon["SEP"]=9; mon["sep"] = 9; mon["Sep"]=9;
    mon["OCT"]=10; mon["oct"] = 10; mon["Oct"]=10;
    mon["NOV"]=11; mon["nov"] = 11; mon["Nov"]=11; 
    mon["DEC"]=12; mon["dec"] = 12; mon["Dec"]=12;
}
{
    # Print result when new address comes along.
    if ($1 != o_adr) {
	if (o_adr != "") print o_line;
	o_adr = "";
	o_line = "";
	o_ndate = "";

    }
    # Convert date to numerical date.
    weekday = substr($3, 1, 3);
    month = substr($3, 5, 3);
    day = substr($3, 9, 2);
    if (day ~ / $/) day = substr(day, 1, 1);
    year = substr($3, 11, 6);
    while (year ~ /^ /) year = substr(year, 2, 6);
    if (year ~ /[0-9]:[0-9]/) {
	# Year is actually a time of day!  Replace it with thisyear..
	year = thisyear;
    }
    ndate = year*10000+mon[month]*100+day;

    # If later than old date, save.
    if (ndate > o_ndate) {
	o_ndate = ndate;
	o_line = $1 "\t" $2 "\t" weekday " " month " " day " " year;
	o_adr = $1;
    }
    next;
}
END { print o_line }
