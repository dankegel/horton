#ifndef lint
static char sccsid[] = "@(#)finger.c	1.1 2/8/92";
#endif

main(argc, argv)
	int argc;
	char **argv;
{
	int i;

	for (i=1; i<argc; i++)
		netfinger(argv[i], 0);
	exit(0);
}
