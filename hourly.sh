#!/bin/csh -f -b
# Script to update directory of e-mail address vs. real name with Finger
# @(#)hourly.sh	1.8 7/8/92
if ($#argv != 2) then
    echo Usage: $0 domain dir
    echo Updates dir/hourly.out.
    exit 1
endif
set DOMAIN = $1
cd $2
#
set TMPFILE = /tmp/hourly.tmp
set DIRECTORY = hourly.dat
set DIRECTORY_DETAB = hourly.out
set HOSTS = hosts.poll
set HOST_XLAT = hosts.xlat
set QUICKFINGER = ./quickfinger
set date = `date | awk '{print $1,$2,$3,$6}'`
#
/bin/rm -f $TMPFILE

# Finger all the hosts.  Use a special finger that times out in 10 seconds.
sed -e 's/^/@/' -e 's/ / @/g' $HOSTS | split -300 - /tmp/hourly.hosts
foreach a (/tmp/hourly.hosts??)
    $QUICKFINGER `cat $a` > $a.out &
end
wait
# Generate script to map hostnames
awk '{print "s/@"$1"/@"$2"/"}' < $HOST_XLAT > $HOST_XLAT.sed
# Parse output of the many finger requests.
# You may need to tweak these to match your local fingers if
# you find invalid entries in the output file.
# (Invalid entries are more of an annoyance than a real problem.)
cat /tmp/hourly.hosts??.out | tr -d '\015' | \
awk -f nukefortune.awk | \
egrep -vi "no one logged|unknown|user|-----" | \
egrep -vi "uucp|error|logging in|login | tty |load av|[ 0123][0-9], [12].*up" |\
awk -f addhostname.awk date="`date | sed 's/ [0-9]*:.*T//' `" - | \
sed -e 's/\[//' -e 's/\]//' -e 's/.'$DOMAIN'//' | uniq > $TMPFILE

# Only enable this section if running on host that has e-mail users
# that show up in utmp but never log in.
if (0) then
    # Also scan localhost with finger, to catch people who log in with POP
    # (requires Dan Kegel's mods to pop server)
    # Caution: contains literal TAB character in sed command.
    set host = `hostname`
    foreach user (`ypcat passwd | sed 's/:.*//' `)
	finger $user | awk -f toshort.awk | \
	sed 's/	/@'$host'	/' >> $TMPFILE
    end
endif

# Add in new results to old results; sort the whole thing
# and discard entries with identical username and realname.
# Caution: contains literal TAB character in sort command.
# Relies on the fact that a TAB character separates the
# three fields of the datafile.
touch $DIRECTORY
set date=`date`
set year=$date[6]
sed -f $HOST_XLAT.sed $TMPFILE $DIRECTORY | sort -f -t'\008' +0 -1 | \
   awk -f sortdate.awk thisyear=$year - > $DIRECTORY.new
mv $DIRECTORY $DIRECTORY.old
mv $DIRECTORY.new $DIRECTORY
# Expand tabs.
awk -F'	' '{printf("%-30s %-25s %-16s\n", $1, $2, $3); next}' $DIRECTORY > $DIRECTORY_DETAB
rm $TMPFILE $HOST_XLAT.sed /tmp/hourly.hosts*

echo hourly: done
exit 0
