#include <unistd.h>
#include <errno.h>
#include <linux/sched.h>
#include <linux/tty.h>
#include <linux/kernel.h>
#include <asm/segment.h>
#include <sys/times.h>
#include <sys/utsname.h>
#include <string.h>

char msg[24];
int len=0;

int sys_iam(const char * name){
    int c=0;
    char temp[24];
    for(c=0;c<=23;c++){
        temp[c]=get_fs_byte(name+c);
        if(temp[c]=='\0'){
            break;
        }
    }
    if(c>=24 && temp[c-1]!='\0'){
        return -(EINVAL);
    }
    len=c;
    strcpy(msg,temp);
    printk("ThreeGold");
    return c;
}

int sys_whoami(char* name, unsigned int size){
    if(len>size){
        return -(EINVAL);
    }
    int c=0;
    for(c=0;c<=len-1;c++){
        put_fs_byte(msg[c],name+c);
    }
    return len;

}