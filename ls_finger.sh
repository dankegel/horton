#!/bin/csh -f
# @(#)ls_finger.sh	1.3 2/21/92
if ($#argv != 1) then
    echo usage: ls_finger.sh domainname \< hostnames
    echo Lists hosts which support finger to ls_finger.out
    exit 1
endif

set FINGER = ./quickfinger

# Split up list of hosts into files of 300 hosts to avoid line length
# limitation on shell (and go faster, too).
# (Shell job status msgs seem to always go to stdout no matter what I do!
#  Thus this script has to write a file, it can't just be a filter. :-( )
sed -e 's/^/@/' -e 's/ / @/g' | split -300 - ls_finger.host
foreach a (ls_finger.host??)
    ($FINGER `cat $a` > $a.out ) >& /dev/null &
end
wait

# Delete garbage on each line before last bracket (needed with some fingers
# which don't output newline between hosts),
# print out hostname of computers that responded with any user-ish info,
# strip brackets from around hostnames,
# delete domain name (and implied leading dot),
# and sort.
sed 's/.* \(\[\)/\1/' ls_finger.*.out | awk -f ls_finger.awk | tr -d '\[\]' \
    | sed s/\\.$1// | sort > ls_finger.out
rm ls_finger.host*
