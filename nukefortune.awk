# @(#)nukefortune.awk	1.1 2/21/92
# Take output of many finger requests
# Print out hostname and user lines; filter out garbage at end
#
# Finger output is assumed to follow the format
#  "[hostname]"
#  garbage
#  users header | "no one logged on"
#  users lines, one user per line
#  blank line
#  garbage
# repeated once for each system fingered.
#
# state  meaning
#  0     waiting for first hostname
#  1     waiting for users header line
#  2     getting users
#  3     ignoring garbage/waiting for next hostname

# Detect hostname
/^\[/ { state=1; print; next }
# Detect users header or no users message
/[Nn]o one logged|unknown|-----|uucp|error|[Ll]ogging in|[Ll]ogin | tty | TTY | load av|LOAD AV|[ 0123][0-9], [12].*[Uu][Pp]/ {state=2; next}
# Print users lines
/^[A-Za-z]/ {
    if (state==1) state=2;
    if (state==2) { print; next}
}
# detect blank line before final garbage
/^ $/ { if (state==2) {state=3; next;} }
# Print final garbage (only during debugging, to make sure it's garbage)
#{ if (state==3) print "Garbage: " $0; next}
