# Makefile for Horton
# @(#)Makefile	1.6 2/22/92
SHELL = /bin/sh
CC = /bin/cc
CFLAGS= -g

# Change DIR to where you want Horton installed
DIR = /etc/horton

CFILES=net.c finger.c whoisd.c
EXEFILES= whoisd quickfinger
SHFILES= hourly.sh ls_finger.sh ls_hosts.sh ls_smtp.sh mailself.sh monthly.sh
AWKFILES= addhostname.awk ls_finger.awk ls_smtp.awk sortdate.awk toshort.awk \
	    recvmail.awk nukefortune.awk
#

all:	$(EXEFILES)

clean:
	rm *.o $(EXEFILES)

shar: README Makefile version $(SHFILES) $(AWKFILES) $(CFILES) dot.plan \
	    hosts.xlat hosts.exclude
	shar README Makefile version $(SHFILES) $(AWKFILES) $(CFILES) dot.plan \
	    hosts.xlat hosts.exclude > horton.shar

whoisd:	 whoisd.o
	$(CC) $(CFLAGS) -o whoisd whoisd.o

quickfinger: finger.o net.o
	$(CC) $(CFLAGS) -o quickfinger finger.o net.o

install: $(EXEFILES) $(AWKFILES) $(SHFILES) hosts.xlat hosts.exclude
	install -m 555 whoisd $(DIR)/in.whoisd
	install -m 555 quickfinger $(DIR)/quickfinger
	install -m 644 addhostname.awk $(DIR)/addhostname.awk
	install -m 644 ls_finger.awk $(DIR)/ls_finger.awk
	install -m 644 ls_smtp.awk $(DIR)/ls_smtp.awk
	install -m 644 recvmail.awk $(DIR)/recvmail.awk
	install -m 644 sortdate.awk $(DIR)/sortdate.awk
	install -m 644 toshort.awk $(DIR)/toshort.awk
	install -m 644 nukefortune.awk $(DIR)/nukefortune.awk
	install -m 755 hourly.sh $(DIR)/hourly.sh
	install -m 755 monthly.sh $(DIR)/monthly.sh
	install -m 755 ls_finger.sh $(DIR)/ls_finger.sh
	install -m 755 ls_hosts.sh $(DIR)/ls_hosts.sh
	install -m 755 ls_smtp.sh $(DIR)/ls_smtp.sh
	install -m 755 mailself.sh $(DIR)/mailself.sh
	# Only install the example host files if none there.
	test -f $(DIR)/hosts.xlat || install -m 644 hosts.xlat $(DIR)/hosts.xlat
	test -f $(DIR)/hosts.exclude || install -m 644 hosts.exclude $(DIR)/hosts.exclude
	@echo Be sure to update /etc/inetd.conf and crontab.
