#!/bin/csh -f
# @(#)ls_hosts.sh	1.3 7/7/92
if ($#argv != 1) then
    echo Usage: ls_hosts  domain  
    echo Lists hostnames, stripped of domain suffix, to stdout.
    exit 1
endif
set echo

if ( -f /etc/resolv.conf && -e /usr/etc/nslookup ) then
    # Use DNS to get hostnames.  Delete any trailing dot (NeXT does this?).
    echo ls $1 | nslookup | egrep -v ':|localhost' | grep '[0-9]\.[0-9]' | \
	sed s/.$1// | sort +1 -u | awk '{print $1}' | tr A-Z a-z | sort -u \
	| sed 's/\.$//' > /tmp/ls_hosts.tmp
    # Sometimes the DNS server doesn't have a list of hosts
    # (e.g. if you use a caching-only server), so try other methods, too.
endif

if ( -e /usr/bin/domainname && `domainname` != noname ) then
    # Use NIS to get hostnames.  Choose first FQDN on line.
    ypcat hosts | tr A-Z a-z | grep -i $1 | grep -v '^#' \
	| sed s/$1.\*/$1/ | tr ' \011' '\012\012' \
	| grep -i $1 | sed s/.$1// | sort -u >> /tmp/ls_hosts.tmp
endif

# Get hostnames from /etc/hosts
cat /etc/hosts | tr A-Z a-z | grep -i $1 | grep -v '^#' \
    | sed s/$1.\*/$1/ | tr ' \011' '\012\012' \
    | grep -i $1 | sed s/.$1// | sort -u >> /tmp/ls_hosts.tmp

# Gather results
sort -u /tmp/ls_hosts.tmp
rm /tmp/ls_hosts.tmp
