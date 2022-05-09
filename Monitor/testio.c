/* needed only for testing -- dirty !! tricks */
#include <stdio.h>

tgetchar()
{
	return(getchar());
}

tputchar(c)
{
	putchar(c);
}
