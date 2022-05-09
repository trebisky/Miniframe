unsigned long
atoh(p)
register char *p;
{
	unsigned long n;

	while ( *p == ' ' || *p == '\t' )
		++p;

	for ( n=0;; ) {
	    if ( *p >= '0' && *p <= '9' )
		n = n<<4 | (*p++ - '0');
	    else if ( *p >= 'a' && *p <= 'f' )
		n = n<<4 | (*p++ - 'a' + 10);
	    else if ( *p >= 'A' && *p <= 'F' )
		n = n<<4 | (*p++ - 'A' + 10);
	    else
		break;
	}
	return ( n );
}
