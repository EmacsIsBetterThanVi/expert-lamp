all: powerkey
powerkey: powerkey.o
  cc powerkey.o -o powerkey 
powerkey.o:
  cc -c powerkey.c -o powerkey.o
install: powerkey
  mv powerkey /bin
  mv powerkey.service /etc/systemd/system
clean:
  rm -f powerkey powerkey.o
