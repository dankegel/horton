# awk script to take multiline-per-user output of Finger's long
# format, and turn it into a one-line-per-user format with
# login name, real name, and last login time.
# @(#)toshort.awk	1.1 2/5/92
/Login name/{ uname = $3; rname = $7 " " $8 " " $9 " " $10 " " $11 }
/Last login/{ print uname "\t" rname "\t" $3 " " $4 " " $5 " " $6;}
{ next; }
