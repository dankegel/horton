#!/bin/csh -f
# @(#)ls_smtp.sh	1.3 7/7/92
# Usage: ls_smtp.sh < hostnames 
# Result to ls_smtp.out
# Send a letter to myself via each given host
#
# Handle 300 hosts at a time to avoid line-length limitations.
# Don't send more than one letter at once, though; e-mail systems are
# fragile.
split -300 - ls_smtp.host
foreach a (ls_smtp.host??)
    (mailself.sh `cat $a` > $a.out ) >& /dev/null 
end
# Create a list of those hosts that accepted the command
awk -f ls_smtp.awk ls_smtp.host*.out | tr A-Z a-z | sort > ls_smtp.out
rm ls_smtp.host* ls_smtp.tmp
