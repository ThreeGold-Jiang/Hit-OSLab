#define __LIBRARY__
#include <unistd.h>
#include<string.h>
#include<stdio.h>
_syscall2(int, whoami,char*,name,unsigned int,size);

int main()
{
	char msg[24];
	int c = 0;
	c = whoami(msg,24);
	printf("%s\n",msg);
	return c;
}
