# Take output of many finger requests
# print it as if it came from one big host with extended usernames
# @(#)addhostname.awk	1.1 2/8/92
/^\[/ { host = $1; next }
/^[A-Za-z]/ {print $1 "@" host "\t" substr($0, 10, 19) "\t" date }
