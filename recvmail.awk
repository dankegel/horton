# @(#)recvmail.awk	1.1 2/11/92
# Awk script to do the following without MH.  Stdin is /var/spool/mail/$USER
# translated to lower case.
# Delete letters that are error messages
#rmm `pick -search error -or -search postmaster -or -search returned`
# Grab name of machine we sent each letter to
#show `pick -search ls_sendlet` |  awk '/ls_sendlet_sent_to/{print $3}' 
#
# "From:" at the start of a line is the mail message delimiter.
/^from:/ {bad=0; next}
# Bad messages contain one of the following words:
/error|postmaster|returned|undeliverable/ {bad=1;}
# If we got to the magic keyword "ls_sendlet_sent_to" without seeing
# an error word, it was a good letter.
/ls_sendlet_sent_to/{if (bad==0) print $3; next}
# Otherwise ignore the line.
{next;}
