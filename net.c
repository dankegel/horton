
#ifndef lint
static char sccsid[] = "@(#)net.c	1.3 7/7/92 from net.c	5.5 (Berkeley) 6/1/90";
#endif /* not lint */

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <signal.h>
#include <netdb.h>
#include <stdio.h>
#include <ctype.h>
#include <setjmp.h>

jmp_buf env;

void handler()
{
	/* return to netfinger() and cause it to terminate.
	 */
	 longjmp(env, 1);
}

netfinger(name, lflag)
	char *name;
	int lflag;
{
	FILE *fp;
	int c, lastc;
	struct in_addr defaddr;
	struct hostent *hp, def;
	struct servent *sp;
	struct sockaddr_in sin;
	int s;
	char *alist[1], *host, *rindex();
	u_long inet_addr();

	if (!(host = rindex(name, '@')))
		return;
	*host++ = NULL;
	if (!(hp = gethostbyname(host))) {
		defaddr.s_addr = inet_addr(host);
		if (defaddr.s_addr == -1) {
			(void)fprintf(stderr,
			    "finger: unknown host: %s\n", host);
			return;
		}
		def.h_name = host;
		def.h_addr_list = alist;
		def.h_addr = (char *)&defaddr;
		def.h_length = sizeof(struct in_addr);
		def.h_addrtype = AF_INET;
		def.h_aliases = 0;
		hp = &def;
	}
	if (!(sp = getservbyname("finger", "tcp"))) {
		(void)fprintf(stderr, "finger: tcp/finger: unknown service\n");
		return;
	}
	sin.sin_family = hp->h_addrtype;
	bcopy(hp->h_addr, (char *)&sin.sin_addr, hp->h_length);
	sin.sin_port = sp->s_port;
	if ((s = socket(hp->h_addrtype, SOCK_STREAM, 0)) < 0) {
		perror("finger: socket");
		return;
	}

	/* have network connection; identify the host connected with */
	if (hp->h_name == NULL)	{
	    fprintf(stderr, "h_name NULL??\n");
	    (void)close(s);
	    return;
	}
	(void)printf("[%s]\n", hp->h_name);
	fflush(stdout);
	if (setjmp(env)) {
		if (hp->h_name == NULL)	/* it happened once? */
		    fprintf(stderr, "Finger: timeout connect (h_name now NULL?!)\n");
		else
		    fprintf(stderr, "Finger: timeout connect %s\n", hp->h_name);
		(void)close(s);
		return;
	}
	alarm(10);
	signal(SIGALRM, handler);
	if (connect(s, (struct sockaddr *)&sin, sizeof(sin)) < 0) {
		perror("finger: connect");
		(void)close(s);
		return;
	}
	alarm(20);	/* once we've connected, give them 20 seconds */
	if (setjmp(env)) {
		printf("\n");
		fflush(stdout);
		fprintf(stderr, "Finger: timeout reading %s\n", hp->h_name);
		(void)close(s);
		return;
	}
	signal(SIGALRM, handler);

	/* -l flag for remote fingerd  */
	if (lflag)
		write(s, "/W ", 3);
	/* send the name followed by <CR><LF> */
	(void)write(s, name, strlen(name));
	(void)write(s, "\r\n", 2);

	/*
	 * Read from the remote system; once we're connected, we assume some
	 * data.  If none arrives, we hang until the user interrupts.
	 *
	 * If we see a <CR> or a <CR> with the high bit set, treat it as
	 * a newline; if followed by a newline character, only output one
	 * newline.
	 *
	 * Otherwise, all high bits are stripped; if it isn't printable and
	 * it isn't a space, we can simply set the 7th bit.  Every ASCII
	 * character with bit 7 set is printable.
	 */ 
	if (fp = fdopen(s, "r"))
		while ((c = getc(fp)) != EOF) {
			c &= 0x7f;
			if (c == 0x0d) {
				c = '\n';
				lastc = '\r';
			} else {
				if (!isprint(c) && !isspace(c))
					c |= 0x40;
				if (lastc != '\r' || c != '\n')
					lastc = c;
				else {
					lastc = '\n';
					continue;
				}
			}
			putchar(c);
		}
	if (lastc != '\n')
		putchar('\n');
	(void)fclose(fp);
}
