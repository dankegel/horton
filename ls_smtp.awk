# Awk script to print out names of hosts responding to an SMTP request
# @(#)ls_smtp.awk	1.2 2/10/92
/connecting/ {host = $4; next}
/^220 / {print host}
