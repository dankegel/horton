/*-------------------------------------------------------------------------- 
 whoisd.c
 Simply runs egrep with the given search string
 on our data file.
 Modified from a whoisd.c found on the net somewhere.
 - Dan Kegel (da...@blacks.jpl.nasa.gov)
--------------------------------------------------------------------------*/
static char SCCSID[] = "@(#)whoisd.c	1.4 7/8/92";

#include <stdio.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <syslog.h>

#define GREP "/usr/bin/egrep"
#define	WORKINGDIR "/tmp"

char	*inet_ntoa();

char *
stream_gets()
{
	register char *cp;
	register i;
	int  loc;
	static char inp_buf[1024];

	cp = inp_buf;
	loc = 0;
	while(loc < 1000) {
		i = read(5, cp, 1);
		if(!i) {
			*cp = 0;
			break;
		}
		if(i < 0) {
			perror("socket read");
			exit(1);
		}
		if(*cp == '\n') break;
		if(*cp == '\r') break;
		cp++;
		loc++;
	}
	*cp = '\0';
	return(inp_buf);
}


#define MAXARGS 10

char  *grep_argv[MAXARGS];

main(argc,argv)
int  argc;
char **argv;
{
	char *cp,*lcp;
	int  i;
	int  argnum;
	struct sockaddr_in sin;

	if (argc != 2) {
		fprintf(stderr, "Usage: %s datafile\n", argv[0]);
		exit(1);
	}
	if(chdir(WORKINGDIR) == -1) {
		perror("chdir");
		exit(1);
	}
#ifndef DEBUG
	i = sizeof(struct sockaddr_in);
	if(getpeername(0, &sin, &i) < 0) {
		perror("getpeername()");
		exit(1);
	}

#ifdef ultrix
	/* Thanks to Dave Dittrich */
	openlog("whoisd", LOG_PID);
#else
	openlog("whoisd", LOG_PID, LOG_DAEMON);
#endif
	syslog(LOG_INFO,"Connection from host '%s'",inet_ntoa(sin.sin_addr));
#endif

	dup2(0,5);
	fclose(stdin);
	fclose(stdout);
	fclose(stderr);

	dup2(5,1);
	dup2(5,2);

	_iob[1] = *fdopen(1,"w");
	_iob[0] = *fdopen(2,"w");


	cp = stream_gets();
	if (strlen(cp) == 0) {
	    printf("Type the name, username, or hostname of the person\n");
	    printf("you are searching for.\n");
	    exit(0);
	}

	argnum = 0;
	grep_argv[argnum++] = "egrep";
	grep_argv[argnum++] = "-i";
	grep_argv[argnum++] = "-e";
	grep_argv[argnum++] = cp;
	grep_argv[argnum++] = argv[1];

#ifndef DEBUG
	syslog(LOG_INFO,"REQUEST '%s'",cp);
	closelog();
#else
	printf("REQUEST '%s'\n", cp);
#endif

	grep_argv[argnum++] = NULL;
	grep_argv[argnum++] = NULL;

	execv(GREP,grep_argv);
	exit(0);
}
