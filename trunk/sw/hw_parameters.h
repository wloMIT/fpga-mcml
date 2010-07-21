
#ifndef NUM_FRESNELS
	#define NUM_FRESNELS 128	// number of elements in the fresnels LUT
#endif

#ifndef NUM_TRIG_ELS
	#define NUM_TRIG_ELS 1024	// number of elements in the trigonometric LUT
#endif

// Total number of constants = 2 * 5 * NUM_TRIG_ELS + 2 * 5 * NUM_FRESNELS + lastConstant
#define TOTAL_CONSTANTS 11624

#define RESET_WAIT 100

#define WSCALE 2E6
#define NR 256
#define NZ 256
