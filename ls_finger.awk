# Awk script to print out hostname (surrounded by square brackets)
# if followed by a line that looks like Finger's short format header
# or Finger's "no users" message.
# @(#)ls_finger.awk	1.1 2/10/92
/^\[/ { host = $1; next }
/[Ll]og|[Pp]ort|[Ll]ine|[Uu]ser/ { if (host != "") { print host; host="" }}
