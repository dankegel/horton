#!/bin/csh -f
# @(#)mailself.sh	1.2 2/22/92
if ($#argv == 0) then
    echo usage: mailself.sh hostname ...
    echo Mails a letter back to the current user by way of each given host.
    echo Also prints out the name of each host that accepted a letter.
    exit 1
endif
# Really, there's no reason to print out the hostname- the real check
# comes when you see if the mail comes back properly- but I do anyway.
# Uses RFC822 source routing, since many SMTP servers (notably TGV's) don't
# understand the user%host1@host2 shorthand.
# Boy, is this nonportable.
set host = `hostname`
foreach b ($*) 
    # mconnect returns 255 if host refuses connection; use this
    # to avoid sending mail to hosts that really don't support SMTP
    mconnect $b < /dev/null > /dev/null
    if ($status) continue

    # Use System V echo; it knows \n means newline.
    # Use sendmail in 'interactive' mode so we can get status return.
    /usr/5bin/echo To: $user@$host\\nFrom: $user@$host\\nSubject: ls_sendlet_sent_to" "$b | \
    /usr/lib/sendmail -di '<@'$b':'$user'@'$host'>' >& /dev/null
    # 0 = success, 64 = bad host, 67 = remote host can't deliver letter
    if ($status == 0 || $status == 67) echo $b
    # Pause to avoid overloading the mail system.
    # System may still choke if hundreds of letters come back all at once,
    # so watch out!
    sleep 10
end
