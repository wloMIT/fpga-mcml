/* A library of routines that will talk to a design using
 * Altera's virtual_jtag interface.
 * The design must contain a communications layer like the
 * one that tmjportmux_gen creates.
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

static char Rcsid[] = "$Header: /jayar/i/tm4/src/jtag_ports/tmjports/RCS/tmports.c,v 1.50 2009/04/16 14:27:25 drg Exp drg $";

#define DEFAULT_TM4HOST   "*"

FILE *to_stp, *from_stp;

static trychip();

#define TM_MAX_PORTS	64

struct portinfo {
   char *name;
   char iox;
   int nbits;
   int needs_ack;
   int chip;
   int port;
} portinfo[TM_MAX_PORTS];

int nports;


static int wait_delay(int nfailures);
static char nib_ascii(int value);
static int ascii_nib(char c);
static int convert_to_bits(char *hex, char *bits);

int tm_init(char *tmhost) {

   /* Create a quartus_stp process, and get the list of ports */

   int i, f_to_stp, f_from_stp;
   char buf[1024], dir[1024];
   struct stat statbuf;
   char *command[] = {"quartus_stp", "-s", 0};

   if(from_stp != (FILE *) NULL) {
      fclose(from_stp);
      fclose(to_stp);
      for(i = 0; i<nports; i++) {
         free(portinfo[nports].name);
      }
      nports = 0;
   }

   piped_child(command, &f_from_stp, &f_to_stp);

   from_stp = fdopen(f_from_stp, "r");
   to_stp = fdopen(f_to_stp, "w");

   if(from_stp == (FILE *) NULL || to_stp == (FILE *) NULL) {
      fprintf(stderr, "tm_init: can't communicate with quartus_stp process\n");
      fclose(from_stp);
      fclose(to_stp);
      from_stp = (FILE *) NULL;
      to_stp = (FILE *) NULL;
      return(-1);
   }

   if((tmhost == (char *) NULL) || (tmhost[0] == '\0')) {
      if((tmhost = getenv("TMJ_SERVER")) == (char *) NULL)
         tmhost = DEFAULT_TM4HOST;
   }

   while(1) {
      fgets(buf, sizeof(buf), from_stp);
      // printf("saw: '%s'\n", buf);
      if(!strcmp(buf, "\n"))
         break;
      if(feof(from_stp)) {
         fprintf(stderr, "saw eof from quartus_stp\n");
         exit(1);
      }

      if(ferror(from_stp)) {
         fprintf(stderr, "saw error from quartus_stp\n");
         exit(1);
      }
   } 

   fprintf(to_stp, "foreach name [get_hardware_names] {\n");
   fprintf(to_stp, "  puts $name\n");
   fprintf(to_stp, "  if { [string match \"*%s*\" $name] } {\n", tmhost);
   fprintf(to_stp, "    set hardware_name $name\n");
   fprintf(to_stp, "  }\n");
   fprintf(to_stp, "}\n");
   fprintf(to_stp, "puts \"\\nhardware_name is $hardware_name\";\n");
   fprintf(to_stp, "foreach name [get_device_names -hardware_name $hardware_name] {\n");
   fprintf(to_stp, "  if { [string match \"@1*\" $name] } {\n");
   fprintf(to_stp, "    set chip_name $name\n");
   fprintf(to_stp, "  }\n");
   fprintf(to_stp, "}\n");
   fprintf(to_stp, "puts \"device_name is $chip_name\\n\";\n");
   fprintf(to_stp, "open_device -hardware_name $hardware_name -device_name $chip_name\n");
   fflush(to_stp);

   while(1) {
      fgets(buf, sizeof(buf), from_stp);
//      printf("saw: '%s'\n", buf);
      if(!strcmp(buf, "\n"))
         break;
      if(feof(from_stp)) {
         fprintf(stderr, "saw eof from quartus_stp\n");
         exit(1);
      }
      if(ferror(from_stp)) {
         fprintf(stderr, "saw error from quartus_stp\n");
         exit(1);
      }
   } 

   strcpy(dir, ".");

   if(stat(dir, &statbuf) == -1) {
      /* The directory doesn't exist, which probably means we're
       * trying to run this on a non-EECG machine.  Fall back to
       * searching the current directory for the ports files.
       */
      strcpy(dir, ".");
   }

   sprintf(buf, "%s/%s%d.ports", dir, "fpga", 0);
   trychip(buf, 0);

   if(nports == 0) {
      fprintf(stderr, "tminit: can't find any ports in file '%s'\n",
         buf);
      fclose(from_stp);
      fclose(to_stp);
      from_stp = (FILE *) NULL;
      to_stp = (FILE *) NULL;
      return(-1);
   }
}



static trychip(char *filename, int chipno) {

   /* Read the list of ports from the given file */

   FILE *portfile;
   char buf[1024], name[1024], mode[1024], handshake_from_circuit[1024], handshake_from_sun[1024]; 
   int nbits, nfields, needs_ack;
   int portno;

   if((portfile = fopen(filename, "r")) == (FILE *) NULL)
      return;

   portno = 0;
   while(1) {
      fgets(buf, sizeof(buf), portfile);
      if(feof(portfile) || ferror(portfile))
         break;
      if((buf[0] == '#') || (buf[0] == '\n'))
         continue;

      nfields = sscanf(buf, "%s %s %d %s %s", name, mode, &nbits,
                                      handshake_from_circuit, handshake_from_sun);
      if(nfields == 3) {
         needs_ack = 0;
      }
      else if(nfields == 5) {
         needs_ack = 1;
      }
      else {
         fprintf(stderr, "tm_init: file %s: don't understand line '%s'", filename, buf);
         continue;
      }

      portinfo[nports].name = strdup(name);
      if(isupper(mode[0]))
         mode[0] = tolower(mode[0]);
      portinfo[nports].iox = mode[0];
      portinfo[nports].nbits = nbits;
      portinfo[nports].needs_ack = needs_ack;
      portinfo[nports].chip = chipno;

      /* Add one to the portnumber to avoid spurious reads from port 0 */
      portinfo[nports].port = portno + 1;

      portno++;
      nports++;
   }

   fclose(portfile);
}



int tm_open(char *portname, char *mode) {

   /* Open the given port.  Return a port descriptor number which can be
    * be passed to tm_read() or tm_write().
    */

   int portno;

   if(from_stp == (FILE *) NULL)
      return(-1);
   
   for(portno = 0; portno < nports; portno++) {
      if(!strcmp(portname, portinfo[portno].name)) {
         switch(portinfo[portno].iox) {

         case 'i':
            if(mode[0] != 'w')
               return(-1);
            break;

         case 'o':
            if(mode[0] != 'r')
               return(-1);
            break;
         }
         return(portno);
      }
   }

   return(-1);
}


tm_get_port_width(char *portname) {

   /* How many bits are in the given port ? */

   int portno;

   if(from_stp == (FILE *) NULL)
      return(-1);
   
   for(portno = 0; portno < nports; portno++) {
      if(!strcmp(portname, portinfo[portno].name)) {
         return(portinfo[portno].nbits);
      }
   }

   return(-1);
}



tm_write(int port, char *buf, int nbytes) {

   /* Send nbytes starting from address buf from the computer to the given
    * port on the design.
    */

   int n, retval, bits_per_transfer, response_byte, packet_id;
   int portbytes, i, nibble, temp;
   char *packet_data_ptr, *itemptr;
   int save_nbytes = nbytes;
   int result_code, nfailures, ntransfers;
   char tempbuf[10240], tempbuf2[2*10240];

   if(to_stp == (FILE *) NULL)
      return(-1);
   if((port < 0) || (port >= nports))
      return(-1);

   if(portinfo[port].iox != 'i')
      return(-1);

   portbytes = (portinfo[port].nbits + 7) / 8;
   if((nbytes % portbytes) != 0)
      return(-1);

   if(portbytes > sizeof(tempbuf)) {
      fprintf(stderr, "tm_write: port too wide\n");
      exit(1);
   }

   fprintf(to_stp, "device_lock -timeout 10000\n");
// printf("send: device_lock -timeout 10000\n");
   fprintf(to_stp, "device_virtual_ir_shift -instance_index 0 -ir_value 2 -no_captured_ir_value\n");
// printf("send: device_virtual_ir_shift -instance_index 0 -ir_value 2 -no_captured_ir_value\n");

   nfailures = 0;
   packet_id = 0;

   while(nbytes > 0) {

      n = nbytes;

      if(n > 1000) {
         n = (1000 / portbytes) * portbytes;
      }

      ntransfers = n / portbytes;

      /* Convert the data to least significant byte first.  */

      if(ntohl(1) == 1) {
         packet_data_ptr = tempbuf;
         for(itemptr = buf; itemptr < &buf[n];
                  itemptr += portbytes) {
            for(i=0; i<portbytes; i++) {
               packet_data_ptr[i] = itemptr[portbytes - 1 - i];
            }
            packet_data_ptr += portbytes;
         }
      }
      else {
         bcopy(buf, tempbuf, n);
      }

      /* 8 bit signature, 8 bit id, 6 bit port address, 12 bits of count,
       * 1 bit of r/w, 1 bit pad
       */

      bits_per_transfer = ntransfers * portbytes * 8 + 8 + 8 + 6 + 12 + 1 + 1;

      fprintf(to_stp, "device_virtual_dr_shift -instance_index 0"
           " -length %d -value_in_hex -dr_value ", bits_per_transfer);
// printf("send: device_virtual_dr_shift -instance_index 0"
//            " -length %d -value_in_hex -dr_value ", bits_per_transfer);

      tempbuf2[0] = 'A';
      tempbuf2[1] = 'C';
      tempbuf2[2] = nib_ascii(packet_id & 0xF);
      tempbuf2[3] = nib_ascii((packet_id>>4) & 0xF);
      packet_id++;

      nibble = (portinfo[port].port >> 4) & 0x3;
      nibble |= (1<<(6-4));	/* Writing */
      tempbuf2[4] = nib_ascii(nibble);

      nibble = portinfo[port].port & 0xF;
      tempbuf2[5] = nib_ascii(nibble);

      temp = ntransfers;
      for(i = 6; i < 9; i++) {
         nibble = (temp >> 8) & 0xF;
         tempbuf2[i] = nib_ascii(nibble);
         temp <<= 4;
      }

      for(i = 0; i < n; i++) {
         nibble = (tempbuf[n-i-1]>>4) & 0xF;
         tempbuf2[9+2*i] = nib_ascii(nibble);

         nibble = tempbuf[n-i-1] & 0xF;
         tempbuf2[9+2*i+1] = nib_ascii(nibble);
      }

      tempbuf2[2*n+9] = '\0';

      fprintf(to_stp, "%s -no_captured_dr_value;\n", tempbuf2); 
// printf("%s -no_captured_dr_value;\n", tempbuf2); 

      fflush(to_stp);

      result_code = -1;

      while(result_code == -1) {
         fprintf(to_stp, "puts \"[device_virtual_dr_shift "
                         " -instance_index 0 -length 1 -value_in_hex ]\\n\";\n");
//    printf("send: puts \"[device_virtual_dr_shift "
//                        " -instance_index 0 -length 1 -value_in_hex ]\\n\";\n");
   
         fflush(to_stp);
   
         while(1) {
            fgets(tempbuf, sizeof(tempbuf), from_stp);
//   printf("saw: '%s'\n", tempbuf);
            if(!strcmp(tempbuf, "\n"))
               break;
            response_byte = tempbuf[strlen(tempbuf) - 2];
            if(feof(from_stp)) {
               fprintf(stderr, "saw eof from quartus_stp\n");
               exit(1);
            }
            if(ferror(from_stp)) {
               fprintf(stderr, "saw error from quartus_stp\n");
               exit(1);
            }
         } 
   
         nibble = ascii_nib(response_byte);
         if(nibble & 0x1)
            result_code = 0;
         else
            result_code = -1;
   
         if(result_code == -1) {
            nfailures++;
            if(wait_delay(nfailures) == -1) {
               break;
            }
            else {
               continue;
            }
         }
         else {
            nfailures = 0;
         }
      }

      if(result_code == -1) {
         break;
      }

      nbytes -= n;
      buf += n;

// printf("nbytes %d n %d\n", nbytes, n);
   }

   fprintf(to_stp, "device_unlock\n");
// printf("send: device_unlock\n");

   return(save_nbytes - nbytes);
}



tm_read(int port, char *buf, int nbytes) {

   /* Transfer nbytes of data from the port on the circuit into memory
    * starting at address buf.
    */

   int n, retval, nibble, bits_per_transfer, response_byte, value, nbits;
   int portbytes, i, j, k, ntransfers, temp, nsuccessful_transfers, packet_id;
   char *response_ptr, *cp, *itemptr, *packet_data_ptr;
   int save_nbytes = nbytes;
   int result_code, nfailures, hexlen;
   char tempbuf[10240], tempbuf2[2*10240], bits[1024 * 8];

   if(to_stp == (FILE *) NULL) {
      fprintf(stderr, "rm_read: to_stp pointer is NULL\n");
      return(-1);
   }

   if((port < 0) || (port >= nports)) {
      fprintf(stderr, "tm_read: port is out of range\n");
      return(-1);
   }

   if(portinfo[port].iox != 'o') {
      fprintf(stderr, "tm_read: port is not readable\n");
      return(-1);
   }

   portbytes = (portinfo[port].nbits + 7) / 8;
   if((nbytes % portbytes) != 0) {
      fprintf(stderr, "tm_read: read length not a multiple of port width\n");
      return(-1);
   }

   fprintf(to_stp, "device_lock -timeout 10000\n");
// printf("send: device_lock -timeout 10000\n");
   fprintf(to_stp, "device_virtual_ir_shift -instance_index 0 -ir_value 2 -no_captured_ir_value\n");
// printf("send: device_virtual_ir_shift -instance_index 0 -ir_value 2 -no_captured_ir_value\n");

   nfailures = 0;
   packet_id = 0;

   while(nbytes > 0) {
      n = nbytes;

      if(n > 1000) {
         n = (1000 / portbytes) * portbytes;
      }

      ntransfers = n / portbytes;

      /* 8 bit signature, 8 bit id, 6 bit port address, 12 bits of count,
       * 1 bit of status, 1 bit pad
       */

      fprintf(to_stp, "device_virtual_dr_shift -instance_index 0"
           " -length %d -value_in_hex -dr_value ", 8 + 8 + 6 + 12 + 1 + 1);
// printf("send: device_virtual_dr_shift -instance_index 0"
//            " -length %d -value_in_hex -dr_value ", 8 + 8 + 6 + 12 + 1 + 1);

      tempbuf2[0] = 'A';
      tempbuf2[1] = 'C';
      tempbuf2[2] = nib_ascii(packet_id & 0xF);
      tempbuf2[3] = nib_ascii((packet_id>>4) & 0xF);
      packet_id++;

      nibble = (portinfo[port].port >> 4) & 0x3;
      nibble |= (0<<(6-4));	/* Reading */
      tempbuf2[4] = nib_ascii(nibble);

      nibble = portinfo[port].port & 0xF;
      tempbuf2[5] = nib_ascii(nibble);

      temp = ntransfers;
      for(i = 6; i < 9; i++) {
         nibble = (temp >> 8) & 0xF;
         tempbuf2[i] = nib_ascii(nibble);
         temp <<= 4;
      }

      tempbuf2[9] = '\0';

      fprintf(to_stp, "%s -no_captured_dr_value;\n", tempbuf2); 
// printf("%s -no_captured_dr_value;\n", tempbuf2); 

      /* 1 status bit per port value transfered */

      bits_per_transfer = ntransfers * (portbytes * 8 + 1);

      fprintf(to_stp, "puts \"[device_virtual_dr_shift "
                      " -instance_index 0 -length %d -value_in_hex ]\\n\";\n",
			bits_per_transfer);
// printf("send: puts \"[device_virtual_dr_shift "
//                       " -instance_index 0 -length %d -value_in_hex ]\\n\";\n",
// 			bits_per_transfer);

      fflush(to_stp);

      tempbuf2[0] = '\0';
      hexlen = (bits_per_transfer + 3) / 4;

      while(1) {
         fgets(tempbuf, sizeof(tempbuf), from_stp);
// printf("saw: '%s'\n", tempbuf);
         if(strlen(tempbuf) > hexlen) {
            response_ptr = &tempbuf[strlen(tempbuf) - hexlen - 1];
            strncpy(tempbuf2, response_ptr, sizeof(tempbuf2) - 1);
            tempbuf2[strlen(tempbuf2) - 1] = '\0';
         }
         if(!strcmp(tempbuf, "\n"))
            break;
         if(feof(from_stp)) {
            fprintf(stderr, "saw eof from quartus_stp\n");
            exit(1);
         }
         if(ferror(from_stp)) {
            fprintf(stderr, "saw error from quartus_stp\n");
            exit(1);
         }
      } 

// printf("tempbuf2 is '%s'\n", tempbuf2);
      nbits = convert_to_bits(tempbuf2, bits);

      nsuccessful_transfers = 0;

      i = nbits - (portbytes * 8 + 1); 

// printf("nbits %d i %d\n", nbits, i);

      while(i >= 0) {
         if(bits[i + portbytes * 8] == 1) {
            for(j = 0; j < portbytes; j++) {
               value = 0;
               for(k = 0; k < 8; k++) {
                  value <<= 1;
                  value |= bits[i + j * 8 + k];
// printf("value 0x%x i %d j %d k %d bitnum %d bit is %d\n", value, i, j, k, i + j * 8 + k, bits[i + j * 8 + k]);
               }
               tempbuf[nsuccessful_transfers * portbytes + j] = value;
// printf("j %d value 0x%x\n", j, value);
            }

            nsuccessful_transfers++;
         }

         i -= portbytes * 8 + 1;
      }

      if(nsuccessful_transfers * portbytes == n) {
         result_code = 0;
      }
      else {
         result_code = -1;
      }

      if(result_code == -1) {
         nfailures++;
// fprintf(stderr, "tm_read: failure %d  transfers %d  wanted %d\n", nfailures, nsuccessful_transfers, n / portbytes);
// fprintf(stderr, "saw: '%s'\n", tempbuf2);
         if(wait_delay(nfailures) == -1) {
            break;
         }
      }
      else {
         nfailures = 0;
      }

      n = nsuccessful_transfers * portbytes;

      /* Convert the data from most significant byte first.  */

      if(ntohl(1) != 1) {
// printf("converting from msb first\n");
         packet_data_ptr = tempbuf;
         for(itemptr = buf; itemptr < &buf[n];
                  itemptr += portbytes) {
            for(i=0; i<portbytes; i++) {
               itemptr[portbytes - 1 - i] = packet_data_ptr[i];
            }
            packet_data_ptr += portbytes;
         }
      }
      else {
         memcpy(buf, tempbuf, n);
      }

      nbytes -= n;
      buf += n;
   }

   fprintf(to_stp, "device_unlock\n");
// printf("send: device_unlock\n");

   return(save_nbytes - nbytes);
}


tm_close(int port) {

   if(to_stp == (FILE *) NULL)
      return(-1);
   if((port < 0) || (port >= nports))
      return(-1);

   if((port < 0) || (port >= nports))
      return(-1);
   return(0);
}



static int wait_delay(int nfailures) {

   /* Sleep for a bit before trying the transfer again */

   int i, exponential;

   exponential = 1;

   for(i = 0; i < nfailures; i++) {
      exponential = exponential * 2;
   }

   if(nfailures < 10) {
      usleep(2000 * exponential);
      return(0);
   }
   else {
      fprintf(stderr, "tmports: more than 9 failed data transfers in a row\n");
      return(-1);
   }
}



static char nib_ascii(int value) {

   /* Return an ascii character that represents this value in hex */

   if(value >= 0 && value <= 9)
      return('0' + value);
   else if(value >= 10 && value <= 15)
      return('A' + value - 10);
   else {
      fprintf(stderr, "nib_ascii: value outside range: %d\n", value);
      abort();
   }

   return('-');
}



static int ascii_nib(char c) {

   /* Take a hex character and return a value from 0-15. */

   if(c >= '0' && c <= '9')
      return(c - '0'); 
   else if(c >= 'A' && c <= 'F')
      return(c - 'A' + 10); 
   else if(c >= 'a' && c <= 'f')
      return(c - 'a' + 10); 
   else {
      fprintf(stderr, "ascii_nib: character outside range: '%c'\n", c);
      abort();
   }

   return(-1);
}



static int convert_to_bits(char *hex, char *bits) {

   /* Convert a long hex string into an array of bits */

   int i, nbits, len, value;

   nbits = 0;
   len = strlen(hex);

   for(i = 0; i < len; i++) {
      value = ascii_nib(hex[i]);
      bits[nbits + 0] = ((value & 0x8) != 0);
      bits[nbits + 1] = ((value & 0x4) != 0);
      bits[nbits + 2] = ((value & 0x2) != 0);
      bits[nbits + 3] = ((value & 0x1) != 0);
      nbits += 4;
   }

   return(nbits);
}
