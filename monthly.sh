#!/bin/csh -f
# @(#)monthly.sh	1.7 7/7/92
# Update $2/hosts.poll by probing for new hosts that support finger AND mail.
# Hosts that are in ls_smtp.out but not in recvmail.out may have mail
# configuration problems; they didn't get mail back to us.
# Dan Kegel (da...@blacks.jpl.nasa.gov)
#
if ($#argv != 2) then
    echo Usage: $0 domain dir
    echo Updates dir/hosts.poll.
    exit 1
endif
set verbose
set DOMAIN = $1
cd $2
#
# Default path doesn't reach nslookup.
set path=(/bin /usr/bin /usr/ucb /etc /usr/etc . $path)
#
# Delete old letters.  This is why this script should be run by a pseudo-user!
/bin/rm /usr/spool/mail/$USER
#
# Get list of all IP hosts in this domain that don't match an exlude list
ls_hosts.sh $DOMAIN | egrep -v -f hosts.exclude > hosts
# and that we don't already monitor
touch hosts.poll
sort hosts.poll > ohosts
comm -23 hosts ohosts > nhosts
#
# Find subset of hosts which run fingerd; result to ls_finger.out.
ls_finger.sh $DOMAIN < nhosts 
#
# Find subset of hosts which run smtpd, and send letters; result to ls_smtp.out
ls_smtp.sh < ls_finger.out
#
# Wait for letters to come back.  Should wait longer, but...
sleep 1000
# Find subset of hosts that returned letters to us successfully
tr A-Z a-z < /usr/spool/mail/$USER | awk -f recvmail.awk | sort -u >recvmail.out
/bin/rm /usr/spool/mail/$USER
#
# Finally, generate list of hosts that support finger AND mail,
join ls_finger.out recvmail.out > hosts.good
# and update old list.
sort -u hosts.good hosts.poll > hosts.new
mv hosts.poll hosts.poll.old
mv hosts.new hosts.poll
rm ?hosts
