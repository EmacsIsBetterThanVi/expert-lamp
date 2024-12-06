#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <time.h>
#include <poll.h>
#include <fcntl.h>
char readc(FILE * file){
  char * c = malloc(2);
  read(fileno(file), c, 1);
  return c[0];
}
int main(){
  unsigned char C = 0;
  FILE * file = fopen("/dev/input/event12", "rb");
  if(!file){
    printf("Failed to open /dev/input/event12\n");
    return 1;
  }
  fcntl(fileno(file), F_SETFL, O_NONBLOCK);
  printf("Input Stream opened\n");
  unsigned char scn=0;
  bool down = false;
  time_t now = time(NULL);
  printf("Shutdown driver started at utime %d, forking to background.\n", now);
  if (!fork()){
  while(true){
    C = (char)fgetc(file);
    if(C == 'O' && scn==0){
      scn=255;
    } else if (C == 'g' && scn==254){
      scn=16;
    } else if (C == 152 && scn==1){
      if(down){
	if((time(NULL)-now)>3){
	  system("shutdown -P now");
	}
      }else{
	down=true;
	now = time(NULL);
	printf("shutdown registered at %d\n", now);
      }
    } else if (scn==253) scn=0;
    if((time(NULL)-now)>4){
      down=false;
    }
    //printf("%c", down+48);
    if(scn>0){
      //      printf("%d:%d;", scn, C);
      scn--;
    }
  }
  }
  printf("Forking complete, resuming previous behavior\n");
  exit(0);
  return 0;
}
