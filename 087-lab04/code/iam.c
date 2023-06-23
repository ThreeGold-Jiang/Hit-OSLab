#define __LIBRARY__ 
#include <unistd.h>
#include <stdio.h>
_syscall1(int, iam, const char*, name);
int main(int argc,char ** argv)
{
	int c = 0;
	if(argc<1)
	{
		printf("without name!\n");
		return -1;
	}
	c = iam(argv[1]);
	return c;
}
