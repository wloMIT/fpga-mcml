/* A program to test a simple counter circuit, using the ports package */

#include <stdio.h>
#include <stdlib.h>


main(argc, argv)
	int argc;
	char *argv[];
	{
	int portresult;
	int *result;
	int i, count;

	tm_init("");

	if((portresult = tm_open("result", "r")) < 0) {
		printf("Can't open port result\n");
		exit(1);
		}

	count = 10;
	if(argc>1)
		count = atoi(argv[1]);

	result = (int *) malloc(count * sizeof(int));
	if(result == NULL) {
		printf("Can't allocate memory\n");
		exit(1);
		}

	if(tm_read(portresult, result, count * sizeof(int))
			!= (count * sizeof(int))) {
		fprintf(stderr, "suncounter: error in reading\n");
		exit(1);
		}

	for(i=0; i<count; i++) {
		printf("%d ", result[i]);
		if((i % 10) == 9) {
			printf("\n");
			}
		}
	printf("\n\n");

	exit(0);
	}
