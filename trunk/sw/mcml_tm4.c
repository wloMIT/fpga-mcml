/* sw/MCML*/
#include "mcml.h"
#include "hw_parameters.h"
#include <time.h>
#include <stdlib.h>

#define DEBUG_WRITE 1

extern int tm_open(char *portname, char *mode);
extern int tm_write(int p, char *buf, int nbytes);
extern int tm_read(int p, char *buf, int nbytes);
extern void tm_init(char *buf);

// local function
static int setStoreVal(int storeCount, ConstStruct Constants);

// DONE: Divide output by WSCALE for a real run!!
static void WriteFile(int Nphotons, long long ** absorbtion_matrix, double dr, double dz);

int main(int argc, char* argv[]) {
	ConstStruct Constants;
	int startTime, startReadTime, startSimTime;

	startTime = time(NULL);

	Constants = MCML_main(argc, argv);

	long long constants_read[TOTAL_CONSTANTS];
	long long **absorbtion_matrix;
	unsigned int read_result;
	long long read_absorb_matrix_value;
	int first_time, toggle;


	char reset;
	char done;
	int constants_array[TOTAL_CONSTANTS];
	char* buffer;

	int i, j;

	int resetPort, constantsPort, resultPort, donePort;

	srand(time(NULL));

	absorbtion_matrix = (long long **) malloc(NR * sizeof(long long *));
	for(i = 0; i < NR; i++) {
		absorbtion_matrix[i] = (long long *) malloc(NZ * sizeof(long long));
	}

	for(i = 0; i < NR; i++)
	{
		for(j = 0; j < NZ; j++)
		{
			absorbtion_matrix[i][j] = 0;
		}
	}

	tm_init("");

		printf("open constants port \n" );
		if((constantsPort = tm_open("constants", "w")) < 0) {
			printf("Can't open port constants %d\n", constantsPort);
			exit(1);
		}

		printf("open reset port \n" );
		if((resetPort = tm_open("reset", "w")) < 0) {
			printf("Can't open port reset %d\n", resetPort);
			exit(1);
		}

		printf("open read port \n" );
		if((resultPort = tm_open("result", "r")) < 0) {
			printf("Can't open port result\n");
			exit(1);
		}

		printf("open done port\n");
		if((donePort = tm_open("done", "r")) < 0) {
			printf("Can't open port done\n");
			exit(1);
		}

		printf("start reset \n");
		for(i = 0; i < RESET_WAIT; i++) {
			reset = (char)1;
			if(tm_write(resetPort, &reset, sizeof(reset)) != sizeof(reset)) {
				printf("%d\n", tm_write(resetPort, &reset, 1));
				printf("Cannot write to port: resetPort\n");
			}
		}

		printf("stop reset \n");
		for(i = 0; i < RESET_WAIT; i++) {
			reset = (char)0;
			if(tm_write(resetPort, &reset, sizeof(reset)) != sizeof(reset)) {
				printf("%d\n", tm_write(resetPort, &reset, sizeof(reset)));
				printf("Cannot write to port: resetPort\n");
			}
		}

		printf("write to port \n");
		for(i = 0; i < TOTAL_CONSTANTS; i++)
		{
			constants_array[i] = setStoreVal(i, Constants);
			#if DEBUG_WRITE
				printf("write constant # %d %08X \n", i, constants_array[i]);
			#endif
			buffer = (char*) &constants_array[i];
			if(tm_write(constantsPort, buffer, sizeof(int)) != sizeof(int)) {
				printf("%d\n", tm_write(constantsPort, buffer, sizeof(int)));
				printf("Cannot write to port: constantsPort\n");
			}
		}
		startSimTime = time(NULL);

		printf("simulate %d photons per FPGA\n", Constants.totalPhotons);
#if 0
		printf("wait until output port is ready\n");

		i = 0;
		j = 0;
		buffer = (char*) &done;
		while((tm_read(donePort, buffer, 1) == 1) && (1 != (int)done)) {
			printf("try to read\n");
			if(i % 1000 == 0) {
				printf(" . ");
				//fflush(stdout);
			}
			i++;
		}
		printf("\n");
#endif

		first_time = 0;
		toggle = 0;
		printf("read absorbtion array\n");
		for(i = 0; i < NR; i++)
		{
			for(j = 0; j < NZ; j++)
			{
				buffer = (char*) &read_result;
				while(tm_read(resultPort, buffer, sizeof(int))
						!= (sizeof(int))) {
					printf(".");
				}
				if(first_time == 0) {
					first_time = 1;
					printf("Sim time is %d sec\n", (time(NULL) - startSimTime));
					startReadTime = time(NULL);
				}
				if(toggle == 0) {
					toggle = 1;
					read_absorb_matrix_value = ((long long) read_result) << 32;
				} else {
					toggle = 0;
					read_absorb_matrix_value = read_result;
				}
				absorbtion_matrix[i][j] += read_absorb_matrix_value;
				printf("i %d j %d read_result = %d\n", i, j, read_result);
				if(toggle == 1) {
					j--;
				}
			}
		}
		printf("Read time is %d sec\n", (time(NULL) - startReadTime));

	WriteFile(Constants.totalPhotons, (long long **)absorbtion_matrix, Constants.dr, Constants.dz);

	printf("Total simulation time is %d sec\n", (time(NULL) - startTime));

	for(i = 0; i < NR; i++) {
		free(absorbtion_matrix[i]);
	}
	free(absorbtion_matrix);

	return 0;// Terminate simulation

}

// Get value from constants_array
int setStoreVal(int storeCount, ConstStruct Constants) {
	int lastConstant = 105;
	int randNum;
	int bitmask[7];
	bitmask[0]=3549849;
	bitmask[1]=-1891598;
	bitmask[2]=4985646;
	bitmask[3]=121658;
	bitmask[4]=889489849;
	bitmask[5]=635421658;
	bitmask[6]=289489849;

	if(storeCount == 0)
		return(Constants.totalPhotons);
	else if (storeCount == 1)
		return(Constants.maxDepth_over_maxRadius);
	else if (storeCount >= 2 && storeCount < 7)
		return(Constants.Mut[storeCount-1]);
	else if (storeCount >= 7 && storeCount < 13)
		return(Constants.downCritAngle[storeCount-7]);
	else if (storeCount >= 13 && storeCount < 19)
		return(Constants.upCritAngle[storeCount-13]);
	else if (storeCount >= 19 && storeCount < 26) {
		randNum = rand();
		if(storeCount %2 == 0)
			randNum *= -1;
		randNum = randNum ^ bitmask[storeCount - 19];
		printf("rand seed %d\n", randNum);
		return randNum;
	}
	else if (storeCount >= 26 && storeCount < 32)
		return(Constants.OneOverMut[storeCount-26]);
	else if (storeCount >= 32 && storeCount < 38)
		return(Constants.OneOver_MutMaxrad[storeCount-32]);
	else if (storeCount >= 38 && storeCount < 44)
		return(Constants.OneOver_MutMaxdep[storeCount-38]);
	 else if (storeCount >= 44 && storeCount < 50)
		return(Constants.z0[storeCount-44]);
	else if (storeCount >= 50 && storeCount < 56)
		return(Constants.z1[storeCount-50]);
	else if (storeCount >= 56 && storeCount < 62)
		return(Constants.muaFraction[storeCount-56]);
	else if (storeCount >= 62 && storeCount < 68)
		return(Constants.mus[storeCount-62]);
	else if (storeCount >= 68 && storeCount < 74)
		return(Constants.down_niOverNt[storeCount-68]);
	else if (storeCount > 74 && storeCount < 80)
		return(Constants.up_niOverNt[storeCount-74]);

	else if (storeCount >= 80 && storeCount < 86) {
		int i;
		//send MSB of long long value
		int returnval = 0;
		for(i=63; i>=32; i--)
			returnval += ( ( (Constants.down_niOverNt_2[storeCount-80]) & ((long long)1<<i) ) >> i ) << i-32;
		return(returnval);
	}
	else if (storeCount >= 86 && storeCount < 92) {
		//send LSB of long long value
		return( (int)(Constants.down_niOverNt_2[storeCount-86]) );
	}
	else if (storeCount >= 92 && storeCount < 98) {
		int i;
		//send MSB of long long value
		int returnval = 0;
		for(i=63; i>=32; i--)
			returnval += ( ( (Constants.up_niOverNt_2[storeCount-92]) & ((long long)1<<i) ) >> i ) << i-32;
		return(returnval);
	}
	else if (storeCount >= 98 && storeCount < 104) {
		//send LSB of long long value
		return( (int)(Constants.up_niOverNt_2[storeCount-98]) );
	}
	else if (storeCount == lastConstant-1)
		return( Constants.initialWeight );

	else if (storeCount >= lastConstant && storeCount < (5*NUM_FRESNELS+lastConstant)) {
		int layer = ((storeCount-lastConstant)/NUM_FRESNELS);
		int index = ((storeCount-lastConstant)%NUM_FRESNELS);
		return(Constants.up_rFresnel[layer][index]);
	}
	else if (storeCount >= (5*NUM_FRESNELS+lastConstant) && storeCount < (2*5*NUM_FRESNELS+lastConstant)) {
		int layer = ((storeCount-lastConstant-5*NUM_FRESNELS)/NUM_FRESNELS);
		int index = ((storeCount-lastConstant-5*NUM_FRESNELS)%NUM_FRESNELS);
		return(Constants.down_rFresnel[layer][index]);
	} else if (storeCount >= (2*5*NUM_FRESNELS+lastConstant) && storeCount < (5*NUM_TRIG_ELS+2*5*NUM_FRESNELS+lastConstant)) {
		int layer = ((storeCount-(2*5*NUM_FRESNELS+lastConstant))/NUM_TRIG_ELS);
		int index = ((storeCount-(2*5*NUM_FRESNELS+lastConstant))%NUM_TRIG_ELS);
		return(Constants.trigVals[layer][index].cost);
	} else if (storeCount >= (5*NUM_TRIG_ELS+2*5*NUM_FRESNELS+lastConstant) && storeCount < (2*5*NUM_TRIG_ELS+2*5*NUM_FRESNELS+lastConstant)) {
		int layer = ((storeCount-(5*NUM_TRIG_ELS+2*5*NUM_FRESNELS+lastConstant))/NUM_TRIG_ELS);
		int index = ((storeCount-(5*NUM_TRIG_ELS+2*5*NUM_FRESNELS+lastConstant))%NUM_TRIG_ELS);
		return(Constants.trigVals[layer][index].sint);
	}
	else
		return(0);
}

// DONE: Divide output by WSCALE for a real run!!
void WriteFile(int Nphotons, long long ** absorbtion_matrix, double dr, double dz) {
	FILE *file;

	file = fopen("Real.mco", "w");
	if (file == NULL)
		nrerror("Cannot open file to write.\n");

	int iz, ir;
	double scale1;

	/* Scale A_rz. */
	scale1 = 2.0*PI*dr*dr*dz*Nphotons;

	for (ir=0; ir<NR; ir++)
		for (iz=0; iz<NZ; iz++) {

			//			if (hw_Constants.A_rz[ir][iz]!=0) {
			//				cout <<"A_rz="<<hw_Constants.A_rz[ir][iz]<<"\t ir="<<ir
			//						<<", iz="<<iz<<endl;
			//				//fprintf(file, "ir=%d, iz=%d", ir, iz);
			//			}
			fprintf(file, "%12.4E ", (double)absorbtion_matrix[ir][iz] / ((ir
					+0.5)*scale1*WSCALE));

			if ( (ir*NZ + iz + 1)%5 == 0)
				fprintf(file, "\n");
		}

	fprintf(file, "\n");

	fclose(file);
}

