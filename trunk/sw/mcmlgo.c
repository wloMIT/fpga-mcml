/***********************************************************
 *  Copyright Univ. of Texas M.D. Anderson Cancer Center
 *  1992.
 *
 *	Launch, move, and record photon weight.
 ****/


#include "mcml.h"
#include "hw_parameters.h"

#include <assert.h>

ConstStruct Constants;

#define PRECISION_REDUCTION 14
/*Reduce precision to 32-14 = 18 bits*/

#define MAX_DIMENSION_SIZE 128
/*Maximum allowable world size (note this is UNMEASURED_FACTOR * size of region of interest)*/

#define MUTMAX_BITS 15
/*maximum MUT is given by 1<<MUTMAX_BITS*/

#define NUM_FRESNELS 128
/* number of elements in the fresnels LUT*/

#define NUM_TRIG_ELS 1024

#define MAX_N 4

#define STANDARDTEST 0
  /* testing program using fixed rnd seed. */

#define PARTIALREFLECTION 0
  /* 1=split photon, 0=statistical reflection. */

#define COSZERO (1.0-1.0E-12)
  /* cosine of about 1e-6 rad. */

#define COS90D  1.0E-6
  /* cosine of about 1.57 - 1e-6 rad. */

#define UNMEASURED_FACTOR 4

#define MAXDEPTH(In_Ptr) In_Ptr->nz*In_Ptr->dz*UNMEASURED_FACTOR
/* jedit MAXDEPTH Calculation is wrong, should use In_Ptr[4].z1 */
#define MAXRADIUS(In_Ptr) In_Ptr->nr*In_Ptr->dr*UNMEASURED_FACTOR


#define INTDEPTH(z, maxdepth) (int)(( z/maxdepth )*INTMAX)

/***********************************************************
 *	A random number generator from Numerical Recipes in C.
 ****/
#define MBIG 1000000000
#define MSEED 161803398
#define MZ 0
#define FAC 1.0E-9

float ran3(int *idum)
{
  static int inext,inextp;
  static long ma[56];
  static int iff=0;
  long mj,mk;
  int i,ii,k;

  if (*idum < 0 || iff == 0) {
    iff=1;
    mj=MSEED-(*idum < 0 ? -*idum : *idum);
    mj %= MBIG;
    ma[55]=mj;
    mk=1;
    for (i=1;i<=54;i++) {
      ii=(21*i) % 55;
      ma[ii]=mk;
      mk=mj-mk;
      if (mk < MZ) mk += MBIG;
      mj=ma[ii];
    }
    for (k=1;k<=4;k++)
      for (i=1;i<=55;i++) {
	ma[i] -= ma[1+(i+30) % 55];
	if (ma[i] < MZ) ma[i] += MBIG;
      }
    inext=0;
    inextp=31;
    *idum=1;
  }
  if (++inext == 56) inext=1;
  if (++inextp == 56) inextp=1;
  mj=ma[inext]-ma[inextp];
  if (mj < MZ) mj += MBIG;
  ma[inext]=mj;
  return mj*FAC;
}

#undef MBIG
#undef MSEED
#undef MZ
#undef FAC



/***********************************************************
 *	Generate a random number between 0 and 1.  Take a
 *	number as seed the first time entering the function.
 *	The seed is limited to 1<<15.
 *	We found that when idum is too large, ran3 may return
 *	numbers beyond 0 and 1.
 ****/
double RandomNum(void)
{
  static Boolean first_time=1;
  static int idum;	/* seed for ran3. */

  if(first_time) {
#if STANDARDTEST /* Use fixed seed to test the program. */
    idum = - 1;
#else
    idum = -(int)time(NULL)%(1<<15);
	  /* use 16-bit integer as the seed. */
#endif
    ran3(&idum);
    first_time = 0;
    idum = 1;
  }

  return( (double)ran3(&idum) );
}






/***********************************************************
 *	Compute the specular reflection.
 *
 *	If the first layer is a turbid medium, use the Fresnel
 *	reflection from the boundary of the first layer as the
 *	specular reflectance.
 *
 *	If the first layer is glass, multiple reflections in
 *	the first layer is considered to get the specular
 *	reflectance.
 *
 *	The subroutine assumes the Layerspecs array is correctly
 *	initialized.
 ****/
double Rspecular(LayerStruct * Layerspecs_Ptr)
{
  double r1, r2;
	/* direct reflections from the 1st and 2nd layers. */
  double temp;

  temp =(Layerspecs_Ptr[0].n - Layerspecs_Ptr[1].n)
	   /(Layerspecs_Ptr[0].n + Layerspecs_Ptr[1].n);
  r1 = temp*temp;

  if((Layerspecs_Ptr[1].mua == 0.0)
  && (Layerspecs_Ptr[1].mus == 0.0))  { /* glass layer. */
    temp = (Layerspecs_Ptr[1].n - Layerspecs_Ptr[2].n)
		  /(Layerspecs_Ptr[1].n + Layerspecs_Ptr[2].n);
    r2 = temp*temp;
    r1 = r1 + (1-r1)*(1-r1)*r2/(1-r1*r2);
  }

  return (r1);
}


/***********************************************************
 *	Initialize a photon packet.
 ****/
void LaunchPhoton(double Rspecular,
				  InputStruct  * In_Ptr,
				  PhotonStruct * Photon_Ptr)
{
  LayerStruct *Layerspecs_Ptr = In_Ptr->layerspecs;
  Photon_Ptr->w	 	= 1.0 - Rspecular;
  Photon_Ptr->dead 	= 0;
  Photon_Ptr->layer = 1;
  Photon_Ptr->sz	= 0;
  Photon_Ptr->sr	= 0;
  Photon_Ptr->sleftz= 0;
  Photon_Ptr->sleftr= 0;

  Photon_Ptr->x 	= 0;
  Photon_Ptr->y	 	= 0;
  Photon_Ptr->z	 	= 0;
  Photon_Ptr->ux	= 0;
  Photon_Ptr->uy	= 0;
  Photon_Ptr->uz	= INTMAX;
}




/***********************************************************
 *	Compute the Fresnel reflectance.
 *
 *	Make sure that the cosine of the incident angle a1
 *	is positive, and the case when the angle is greater
 *	than the critical angle is ruled out.
 *
 * 	Avoid trigonometric function operations as much as
 *	possible, because they are computation-intensive.
 ****/
void RFresnel(int n1,	/* incident refractive index.*/
				int n2,	/* transmit refractive index.*/
				int ca1,	/* cosine of the incident */
							/* angle. 0<a1<90 degrees. */
				int * ca2_Ptr)  /* pointer to the */
							/* cosine of the transmission */
							/* angle. a2>0. */
{

   if(n1==n2) {			  	/** matched boundary. **/
    *ca2_Ptr = ca1;
   }
  else if( (double)ca1/INTMAX>COSZERO) {	/** normal incident. **/
    *ca2_Ptr = ca1;
  }
  else if( (double)ca1/INTMAX<COS90D)  {	/** very slant. **/
    *ca2_Ptr = 0;
  }

  else  {			  		/** general. **/
    int sa1, sa2;
	  /* sine of the incident and transmission angles. */

    sa1 = (int)sqrt((long long)INTMAX*(long long)INTMAX-(long long)ca1*(long long)ca1);
    sa2 = (int)(( (long long)sa1 * (long long)n1)/n2);

    if(sa2<0)
	  /* double check for total internal reflection. */
      *ca2_Ptr = 0;
    else
      *ca2_Ptr = (int)sqrt((long long)INTMAX*(long long)INTMAX-(long long)sa2*(long long)sa2);
  }
}



/***********************************************************
 *	Move the photon s away in the current layer of medium.
 ****/
void Hop(InputStruct  *	In_Ptr,
		  PhotonStruct *	Photon_Ptr,
		  OutStruct *		Out_Ptr)
{
	long long xresult, yresult, zresult;

	/*Do integer multiplication*/
  xresult = (long long)((long long)Photon_Ptr->sr*(long long)Photon_Ptr->ux);
  yresult = (long long)((long long)Photon_Ptr->sr*(long long)Photon_Ptr->uy);
  zresult = (long long)((long long)Photon_Ptr->sz*(long long)Photon_Ptr->uz);

	/*Bit shift to rescale*/
  xresult = xresult >> 31;
  yresult = yresult >> 31;
  zresult = zresult >> 31;

	/*Calculate x position, photon dies if outside grid*/
  if((Photon_Ptr->x + xresult) > INTMAX) {
	  	Photon_Ptr->dead = 1;
	  	Photon_Ptr->x = INTMAX;
	} else if ((Photon_Ptr->x + xresult) < INTMIN){
		Photon_Ptr->dead = 1;
	  	Photon_Ptr->x = INTMIN;
	} else {
		Photon_Ptr->x += xresult;
	}

	/*Calculate y position, photon dies if outside grid*/
  if((Photon_Ptr->y + yresult) > INTMAX) {
	  	Photon_Ptr->dead = 1;
	  	Photon_Ptr->y = INTMAX;
	} else if((Photon_Ptr->y + yresult) < INTMIN) {
	  	Photon_Ptr->dead = 1;
	  	Photon_Ptr->y = INTMIN;
	} else {
		Photon_Ptr->y += yresult;
	}

	/*Calculate z position, photon dies if outside grid*/
  if((Photon_Ptr->z + zresult) > INTMAX) {
	  Photon_Ptr->dead = 1;
	  Photon_Ptr->z = INTMAX;
  	} else if((Photon_Ptr->z + zresult) < INTMIN) {
	  Photon_Ptr->dead = 1;
	  Photon_Ptr->z = INTMIN;
  	} else {
		Photon_Ptr->z += zresult;
  	}

}

/***********************************************************
 *	Drop photon weight inside the tissue (not glass).
 *
 *  The photon is assumed not dead.
 *
 *	The weight drop is dw = w*mua/(mua+mus).
 *
 *	The dropped weight is assigned to the absorption array
 *	elements.
 ****/
void Drop(InputStruct  *	In_Ptr,
		  PhotonStruct *	Photon_Ptr,
		  OutStruct *		Out_Ptr)
{
  float dwa;		/* absorbed weight.*/
  int x = Photon_Ptr->x;
  int y = Photon_Ptr->y;
  long long x2, y2;
  int izd, ird;	/* LW 5/20/98. To avoid out of short range.*/
  short  iz, ir;	/* index to z & r. */
  short  layer = Photon_Ptr->layer;
  float mua, mus;

  /* compute array indices. */
  izd = (int)(Photon_Ptr->z/((long long)(In_Ptr->dz*INTMAX*(INTMAX/MAX_DIMENSION_SIZE))/Constants.maxDepth));
  if(izd>In_Ptr->nz-1) iz=In_Ptr->nz-1;
  else iz = izd;

	/*x^2, y^2 calculation*/
  x2 = (long long)((long long)x*(long long)x);
  y2 = (long long)((long long)y*(long long)y);

	/*Note no >>31 here.  That causes the sqrt to give the wrong result, or loses
	the lower 16 bits of precision*/



	/*Within grid, outside cylinder of interest*/
  if ((float)(x2 + y2) > (float)INTMAX*INTMAX) {
	  Photon_Ptr->dead = 1;
	  ir = In_Ptr->nr-1;
	  dwa = Photon_Ptr->w;
  }
  /*Inside cylinder of interest*/
  else {
	  ird = (int)(sqrt( (float)(x2 + y2))/( (long long)(In_Ptr->dr*INTMAX*(INTMAX/MAX_DIMENSION_SIZE))/Constants.maxRadius));
	  if(ird>In_Ptr->nr-1) ir=In_Ptr->nr-1;
	  else ir = ird;
	  mua = In_Ptr->layerspecs[layer].mua;
	  mus = In_Ptr->layerspecs[layer].mus;
	  dwa = Photon_Ptr->w * mua/(mua+mus);
  }
  /*fell through cylinder*/
  if (Photon_Ptr->z == INTMAX) {
  	  Photon_Ptr->dead = 1;
  	  iz = In_Ptr->nz - 1;
  	  dwa = Photon_Ptr->w;
  }

  /* update photon weight. */
  Photon_Ptr->w -= dwa;

  /* assign dwa to the absorption array element. */
  Out_Ptr->A_rz[ir][iz]	+= dwa;
}


/***********************************************************
 *	Choose a new direction for photon propagation by
 *	sampling the polar deflection angle theta and the
 *	azimuthal angle psi.
 *
 *	KEITH'S NOTE:
 *	This function will likely have to be implemented as a LUT.
 *	Expect a minimum memory usage between 10-100KB, but can
 *	be shared amongst all photon calculators.
 *
 *	Note:
 *  	theta: 0 - pi so sin(theta) is always positive
 *  	feel free to use sqrt() for cos(theta).
 *
 *  	psi:   0 - 2pi
 *  	for 0-pi  sin(psi) is +
 *  	for pi-2pi sin(psi) is -
 ****/
void Spin(double g,
		  PhotonStruct * Photon_Ptr)
{
  int cost, sint;	/* cosine and sine of the */
						/* polar deflection angle theta. */
  int cosp, sinp;	/* cosine and sine of the */
						/* azimuthal angle psi. */
  int ux = Photon_Ptr->ux;
  int uy = Photon_Ptr->uy;
  int uz = Photon_Ptr->uz;
  int ux1, uy1, uz1;
  int rnd1, rnd2;
  int tindex, pindex;
  long long sintcosp;
  long long sintsinp;
  long long temp;
  //long long intmax_2 = (long long)(((int)INTMAX>>PRECISION_REDUCTION)<<PRECISION_REDUCTION)*(long long)(((int)INTMAX>>PRECISION_REDUCTION)<<PRECISION_REDUCTION);
  int intmax_1 = (int)INTMAX;
  intmax_1 = intmax_1 >> PRECISION_REDUCTION;
  intmax_1 = intmax_1 << PRECISION_REDUCTION;
  long long intmax_2 = (long long)INTMAX;
  intmax_2 = intmax_2 >> PRECISION_REDUCTION;
  intmax_2 = intmax_2 << PRECISION_REDUCTION;
  intmax_2 *= intmax_2;


  rnd1 = (int)(RandomNum()*INTMAX);
  rnd2 = (int)(RandomNum()*INTMAX);

  /*Calculate indices*/
  tindex = (int)(( (long long)rnd1*NUM_TRIG_ELS)>>31);
  pindex = (int)(( (long long)rnd2*NUM_TRIG_ELS)>>31);

  /*grab values from LUT*/
  cost = Constants.trigVals[Photon_Ptr->layer-1][tindex].cost;
  sint = Constants.trigVals[Photon_Ptr->layer-1][tindex].sint;
  cosp = Constants.trigVals[Photon_Ptr->layer-1][pindex].cosp;
  sinp = Constants.trigVals[Photon_Ptr->layer-1][pindex].sinp;


  /*required values*/
  sintcosp = (long long)sint*(long long)cosp;
  sintcosp = sintcosp >> 31;
  sintsinp = (long long)sint*(long long)sinp;
  sintsinp = sintsinp >> 31;


  if(fabs((double)uz/intmax_1) > COSZERO)  { 	/* normal incident. */
    Photon_Ptr->ux = (int)(sintcosp);
    Photon_Ptr->uy = (int)(sintsinp);
    Photon_Ptr->uz = (int)(cost*SIGN(uz));
	  /* SIGN() is faster than division. */
  }
  else  {		/* regular incident. */

    /*three elements in calculation of ux, uy.  Created for readability*/
    int el1, el2, el3;

    /*temp = 1/sqrt(1-uz^2)*/
    temp = (long long)uz*(long long)uz;
    //temp = (long long)((long long)INTMAX*(long long)INTMAX) - (long long)temp;
    temp = intmax_2 - (long long)temp;
    temp = (long long)sqrt( (double)temp);
  	//temp = (long long)( ( (long long)INTMAX*INTMAX)/(long long)temp);
  	temp = (long long)( ( intmax_2)/(long long)temp);

	/*el1 = sinp*cosp*ux*uz/sqrt(1-uz^2)*/
	el1 = (int)((((((sintcosp*(long long)ux)>>31)*(long long)uz)>>31)*temp)>>31);
	/*el2 = uy*sinp*sint/sqrt(1-uz^2)*/
	el2 = (int)(((( (long long)uy*sintsinp)>>31)*temp)>>31);
	/*el3 = ux*cost*/
	el3 = (int)(( (long long)ux*(long long)cost)>>31);


	Photon_Ptr->ux = el1 - el2 + el3;

	/*el1 = sinp*cosp*uy*uz/sqrt(1-uz^2)*/
	el1 = (int)((((((sintcosp*(long long)uy)>>31)*(long long)uz)>>31)*temp)>>31);
	/*el2 = ux*sinp*sint/sqrt(1-uz^2)*/
	el2 = (int)(((( (long long)ux*sintsinp)>>31)*temp)>>31);
	/*el3 = uy*cost*/
	el3 = (int)(( (long long)uy*(long long)cost)>>31);

	Photon_Ptr->uy = el1 + el2 + el3;

	/*although there's a divide here, this can be eliminated by calculating uz before the last assignment of
	temp (temp = INTMAX^2/temp).  In this case, the /temp becomes *temp (divide becomes multiply)*/
	Photon_Ptr->uz = (int)( ((-sintcosp<<31)/temp)
							+ (( (long long)uz*cost)>>31) );
  }
}





/***********************************************************
 *	Decide whether the photon will be transmitted or
 *	reflected on the upper boundary (uz<0) of the current
 *	layer.
 *
 *	KEITH'S NOTE:
 *	Probaby going to have to implement most of this (esp. the
 *	Fresnel in a LUT of some sort
 *
 *
 *
 *	If "layer" is the first layer, the photon packet will
 *	be partially transmitted and partially reflected if
 *	PARTIALREFLECTION is set to 1,
 *	or the photon packet will be either transmitted or
 *	reflected determined statistically if PARTIALREFLECTION
 *	is set to 0.
 *
 *	Record the transmitted photon weight as reflection.
 *
 *	If the "layer" is not the first layer and the photon
 *	packet is transmitted, move the photon to "layer-1".
 *
 *	Update the photon parmameters.
 ****/
void CrossUpOrNot(InputStruct  *	In_Ptr,
				  PhotonStruct *	Photon_Ptr,
				  OutStruct *		Out_Ptr)
{
  int uz = Photon_Ptr->uz;	/* z directional cosine. */
  int uz1;					/* cosines of transmission alpha. always */
							/* positive. */
  int r=0;				/* reflectance */


  short  layer = Photon_Ptr->layer;
  int ni = Constants.n[layer];
  int nt = Constants.n[layer-1];
  int rnd;


  /* Get r. */
  if( - uz <= (int)(In_Ptr->layerspecs[layer].cos_crit0*INTMAX))
    r=INTMAX;		      /* total internal reflection. */
  else {
  	if(-uz < Constants.upCritAngle[layer-1])
  	  	r = INTMAX;	/*total internal reflection*/
  	  else {
		/*compute uz1 the normal way to maintain acceptable precision*/
  		RFresnel(ni, nt, -uz, &uz1);
  	  	if (uz == INTMIN)
  	  		r = Constants.up_rFresnel[layer-1][NUM_FRESNELS-1];
  	  	else
  	  		r = Constants.up_rFresnel[layer-1][(int)(((long long)-uz*NUM_FRESNELS)/INTMAX)];
  	  }

  }
  rnd = (int)(RandomNum()*INTMAX);


	/*Photon left the tissue entirely, do not absorb its weight, kill photon*/
  if(rnd > r) {		/* transmitted to layer-1. */
    if(layer==1)  {
      Photon_Ptr->uz = -uz1;
      Photon_Ptr->w = 0.0;
      Photon_Ptr->dead = 1;
    }
    else {
      Photon_Ptr->layer--;
      Photon_Ptr->ux = (int) (( (long long)Photon_Ptr->ux*(long long)ni)/nt);
      Photon_Ptr->uy = (int) (( (long long)Photon_Ptr->uy*(long long)ni)/nt);
      Photon_Ptr->uz = -uz1;
    }
  }
  else 						/* reflected. */
    Photon_Ptr->uz = -uz;

}

/***********************************************************
 *	Decide whether the photon will be transmitted  or be
 *	reflected on the bottom boundary (uz>0) of the current
 *	layer.
 *
 *	If the photon is transmitted, move the photon to
 *	"layer+1". If "layer" is the last layer, record the
 *	transmitted weight as transmittance. See comments for
 *	CrossUpOrNot.
 *
 *	Update the photon parmameters.
 ****/
void CrossDnOrNot(InputStruct  *	In_Ptr,
				  PhotonStruct *	Photon_Ptr,
				  OutStruct *		Out_Ptr)
{
  int uz = Photon_Ptr->uz; /* z directional cosine. */
  int uz1;	/* cosines of transmission alpha. */
  int r=0;	/* reflectance */

  short  layer = Photon_Ptr->layer;
  int ni = Constants.n[layer];
  int nt = Constants.n[layer+1];

  int rnd;



  /* Get r. */
  if( uz <= (int)(In_Ptr->layerspecs[layer].cos_crit1*INTMAX))
    r=INTMAX;		/* total internal reflection. */
  else {
	  /* if angle is sharper than critical angle, total internal reflection*/
	  if(uz < Constants.downCritAngle[layer-1])
	  	r = INTMAX;	/*total internal reflection*/
	  else {
		/*Calculate uz1 normally, creates too much error otherwise*/
		RFresnel(ni, nt, uz, &uz1);
		/*use look-up table to get r-value*/
	  	if(Photon_Ptr->uz == INTMAX)
	  		r = Constants.down_rFresnel[layer-1][(int)NUM_FRESNELS-1];
	  	else
	  		r = Constants.down_rFresnel[layer-1][(int)(((long long)uz*NUM_FRESNELS)/(long long)INTMAX)];
  	  }
  }
  rnd = (int)(RandomNum()*INTMAX);

  if(rnd > r) {		/* transmitted to layer+1. */
    if(layer == In_Ptr->num_layers) {
      Photon_Ptr->uz = uz1;
      Photon_Ptr->w = 0.0;
      Photon_Ptr->dead = 1;
    }
    else {
      Photon_Ptr->layer++;
      Photon_Ptr->ux = (int) (( (long long)Photon_Ptr->ux*(long long)ni)/nt);
      Photon_Ptr->uy = (int) (( (long long)Photon_Ptr->uy*(long long)ni)/nt);
      Photon_Ptr->uz = uz1;
    }
  }
  else 						/* reflected. */
    Photon_Ptr->uz = -uz;

}

/***********************************************************
 ****/
void CrossOrNot(InputStruct  *	In_Ptr,
				PhotonStruct *	Photon_Ptr,
				OutStruct    *	Out_Ptr)
{
  if(Photon_Ptr->uz < 0)
    CrossUpOrNot(In_Ptr, Photon_Ptr, Out_Ptr);
  else
    CrossDnOrNot(In_Ptr, Photon_Ptr, Out_Ptr);
}






/***********************************************************
 *	Check if the step will hit the boundary.
 *	Return 1 if hit boundary.
 *	Return 0 otherwise.
 *
 * 	If the projected step hits the boundary, the members
 *	s and sleft of Photon_Ptr are updated.
 ****/
Boolean HitBoundary(PhotonStruct *  Photon_Ptr,
					InputStruct  *  In_Ptr)
{
  long long dl_b;  /* length to boundary. */
  short  layer = Photon_Ptr->layer;
  long long uz = Photon_Ptr->uz;
  Boolean hit;


  /* Distance to the boundary. */
  if(uz>0)
  	/*integer depth of lower boundary minus current z position projected onto z direction*/
  	dl_b = (long long)( (( (long long)( (long long)(In_Ptr->layerspecs[layer].z1*( (long long)INTMAX/ (long long)MAX_DIMENSION_SIZE)* (long long)INTMAX)/ (long long)Constants.maxDepth)- (long long)Photon_Ptr->z)<<31) / ((long long)uz));	/* dl_b>0. */
  else if(uz<0)
  	/*integer depth of upper boundary minus current z position projected onto z direction*/
  	dl_b = (long long)( (( (long long)( (long long)(In_Ptr->layerspecs[layer].z0*(INTMAX/MAX_DIMENSION_SIZE)*INTMAX)/Constants.maxDepth)- (long long)Photon_Ptr->z)<<31) / ((long long)uz));	/* dl_b>0. */

  if(uz != 0 && Photon_Ptr->sz > dl_b) {
	  /* not horizontal & crossing. */

	/*step left = (original step - distance travelled) * scaling factor*/
    Photon_Ptr->sleftz = (long long)((((long long)Photon_Ptr->sz - dl_b)*(long long)Constants.Mut[layer])>>(31-MUTMAX_BITS));


    if((long long)Photon_Ptr->sleftz < 0) {
    	printf("Error!!!\t%f\n", (float)(Photon_Ptr->sleftz));
    	scanf("%d", &layer);
	}

    /*additional scaling factor on dl_b to switch to r-dimension scale*/
     //Photon_Ptr->sleftr = (long long)(maxdepth/maxradius*Photon_Ptr->sleftz);
     Photon_Ptr->sleftr = (long long)(( (long long)Constants.maxDepth*Photon_Ptr->sleftz)/(long long)Constants.maxRadius);

    Photon_Ptr->sz    = dl_b;
    Photon_Ptr->sr = (int)(( (long long)Constants.maxDepth*dl_b)/(long long)Constants.maxRadius);
    hit = 1;
  }
  else
    hit = 0;

  return(hit);
}



/***********************************************************
 *	Pick a step size for a photon packet when it is in
 *	tissue.
 *	If the member sleft is zero, make a new step size
 *	with: -log(rnd)/(mua+mus).
 *	Otherwise, pick up the leftover in sleft.
 *
 *	Layer is the index to layer.
 *	In_Ptr is the input parameters.
 ****/
void StepSizeInTissue(PhotonStruct * Photon_Ptr,
					  InputStruct  * In_Ptr)
{
  char temp;
  short  layer = Photon_Ptr->layer;
  long long rtempstep, ztempstep;
  long long SCALEFACTOR = INTMAX/32;

  if(Photon_Ptr->sleftz == 0) {  /* make a new step. */
    double rnd;

    do rnd = RandomNum();
      while( rnd <= 0.0 );    /* avoid zero. */

	rtempstep = (long long)( (long long)((long long)Constants.logIntmax-(long long)(log(rnd*INTMAX)*SCALEFACTOR)) *(long long)Constants.OneOver_MutMaxrad[layer]);
	ztempstep = (long long)( (long long)((long long)Constants.logIntmax-(long long)(log(rnd*INTMAX)*SCALEFACTOR)) *(long long)Constants.OneOver_MutMaxdep[layer]);

	rtempstep /= SCALEFACTOR;
	ztempstep /= SCALEFACTOR;

	/*boundary check*/
	if (rtempstep > INTMAX || rtempstep < 0) {
		Photon_Ptr->sr = INTMAX;
	}
	/*Scale to grid*/
	else
		Photon_Ptr->sr = (int)rtempstep;

	/*boundary check*/
	if (ztempstep > INTMAX || ztempstep < 0)
		Photon_Ptr->sz = INTMAX;
	/*Scale to grid*/
	else
		Photon_Ptr->sz = (int)ztempstep;

  }


 else {	/* take the leftover. */

  	/*sz*/
  	if (Photon_Ptr->sleftz < 0) {
		Photon_Ptr->sz	= (int)(( (long long)INTMAX*(long long)Constants.OneOverMut[layer])>>31);
		printf("sleftz is less than 0, should not happen\n");
	}
	else
  		Photon_Ptr->sz	= (int)(( (long long)Photon_Ptr->sleftz*(long long)Constants.OneOverMut[layer])>>31);

  	/*sr*/
  	if(Photon_Ptr->sleftr < 0) {
  		Photon_Ptr->sr	= (int)(( (long long)INTMAX*(long long)Constants.OneOverMut[layer])>>31);
  		printf("sleftr is less than 0, should not happen\n");
	}
  	else
  		Photon_Ptr->sr	= (int)(( (long long)Photon_Ptr->sleftr*(long long)Constants.OneOverMut[layer])>>31);

	Photon_Ptr->sleftz	= 0;
	Photon_Ptr->sleftr	= 0;
  }


}

/***********************************************************
 *	Set a step size, move the photon, drop some weight,
 *	choose a new photon direction for propagation.
 *
 *	When a step size is long enough for the photon to
 *	hit an interface, this step is divided into two steps.
 *	First, move the photon to the boundary free of
 *	absorption or scattering, then decide whether the
 *	photon is reflected or transmitted.
 *	Then move the photon in the current or transmission
 *	medium with the unfinished stepsize to interaction
 *	site.  If the unfinished stepsize is still too long,
 *	repeat the above process.
 ****/
void HopDropSpinInTissue(InputStruct  *  In_Ptr,
						 PhotonStruct *  Photon_Ptr,
						 OutStruct    *  Out_Ptr)
{


int tempuz;

Photon_Ptr->x = Photon_Ptr->x >> PRECISION_REDUCTION;
	  	Photon_Ptr->x = Photon_Ptr->x << PRECISION_REDUCTION;
	  	Photon_Ptr->y = Photon_Ptr->y >> PRECISION_REDUCTION;
	  	Photon_Ptr->y = Photon_Ptr->y << PRECISION_REDUCTION;
	  	Photon_Ptr->z = Photon_Ptr->z >> PRECISION_REDUCTION;
	  	Photon_Ptr->z = Photon_Ptr->z << PRECISION_REDUCTION;
	  		Photon_Ptr->ux = Photon_Ptr->ux >> PRECISION_REDUCTION;
					  	Photon_Ptr->ux = Photon_Ptr->ux << PRECISION_REDUCTION;
					   	Photon_Ptr->uy = Photon_Ptr->uy >> PRECISION_REDUCTION;
	   	Photon_Ptr->uy = Photon_Ptr->uy << PRECISION_REDUCTION;






	/*Calculate step size*/
  StepSizeInTissue(Photon_Ptr, In_Ptr);
  Photon_Ptr->x = Photon_Ptr->x >> PRECISION_REDUCTION;
  	  	Photon_Ptr->x = Photon_Ptr->x << PRECISION_REDUCTION;
  	  	Photon_Ptr->y = Photon_Ptr->y >> PRECISION_REDUCTION;
  	  	Photon_Ptr->y = Photon_Ptr->y << PRECISION_REDUCTION;
  	  	Photon_Ptr->z = Photon_Ptr->z >> PRECISION_REDUCTION;
	  	Photon_Ptr->z = Photon_Ptr->z << PRECISION_REDUCTION;
	  		Photon_Ptr->ux = Photon_Ptr->ux >> PRECISION_REDUCTION;
					  	Photon_Ptr->ux = Photon_Ptr->ux << PRECISION_REDUCTION;
					   	Photon_Ptr->uy = Photon_Ptr->uy >> PRECISION_REDUCTION;
	   	Photon_Ptr->uy = Photon_Ptr->uy << PRECISION_REDUCTION;
	/*Determine whether or not photon hit boundary on first step*/
  if (HitBoundary(Photon_Ptr, In_Ptr)) {
	  Photon_Ptr->x = Photon_Ptr->x >> PRECISION_REDUCTION;
	  	  	Photon_Ptr->x = Photon_Ptr->x << PRECISION_REDUCTION;
	  	  	Photon_Ptr->y = Photon_Ptr->y >> PRECISION_REDUCTION;
	  	  	Photon_Ptr->y = Photon_Ptr->y << PRECISION_REDUCTION;
	  	  	Photon_Ptr->z = Photon_Ptr->z >> PRECISION_REDUCTION;
	  	Photon_Ptr->z = Photon_Ptr->z << PRECISION_REDUCTION;
	  		Photon_Ptr->ux = Photon_Ptr->ux >> PRECISION_REDUCTION;
					  	Photon_Ptr->ux = Photon_Ptr->ux << PRECISION_REDUCTION;
					   	Photon_Ptr->uy = Photon_Ptr->uy >> PRECISION_REDUCTION;
	   	Photon_Ptr->uy = Photon_Ptr->uy << PRECISION_REDUCTION;
  	    Hop(In_Ptr, Photon_Ptr, Out_Ptr);	/* move to boundary plane. */
  	    Photon_Ptr->x = Photon_Ptr->x >> PRECISION_REDUCTION;
			  	Photon_Ptr->x = Photon_Ptr->x << PRECISION_REDUCTION;
			  	Photon_Ptr->y = Photon_Ptr->y >> PRECISION_REDUCTION;
			  	Photon_Ptr->y = Photon_Ptr->y << PRECISION_REDUCTION;
			  	Photon_Ptr->z = Photon_Ptr->z >> PRECISION_REDUCTION;
	  	Photon_Ptr->z = Photon_Ptr->z << PRECISION_REDUCTION;
	  		Photon_Ptr->ux = Photon_Ptr->ux >> PRECISION_REDUCTION;
					  	Photon_Ptr->ux = Photon_Ptr->ux << PRECISION_REDUCTION;
					   	Photon_Ptr->uy = Photon_Ptr->uy >> PRECISION_REDUCTION;
	   	Photon_Ptr->uy = Photon_Ptr->uy << PRECISION_REDUCTION;
    	CrossOrNot(In_Ptr, Photon_Ptr, Out_Ptr);
    	Photon_Ptr->x = Photon_Ptr->x >> PRECISION_REDUCTION;
			  	Photon_Ptr->x = Photon_Ptr->x << PRECISION_REDUCTION;
			  	Photon_Ptr->y = Photon_Ptr->y >> PRECISION_REDUCTION;
			  	Photon_Ptr->y = Photon_Ptr->y << PRECISION_REDUCTION;
			  	Photon_Ptr->z = Photon_Ptr->z >> PRECISION_REDUCTION;
	  	Photon_Ptr->z = Photon_Ptr->z << PRECISION_REDUCTION;
	  	Photon_Ptr->ux = Photon_Ptr->ux >> PRECISION_REDUCTION;
			  	Photon_Ptr->ux = Photon_Ptr->ux << PRECISION_REDUCTION;
			   	Photon_Ptr->uy = Photon_Ptr->uy >> PRECISION_REDUCTION;
	   	Photon_Ptr->uy = Photon_Ptr->uy << PRECISION_REDUCTION;
  } else {
	  Photon_Ptr->x = Photon_Ptr->x >> PRECISION_REDUCTION;
	  	  	Photon_Ptr->x = Photon_Ptr->x << PRECISION_REDUCTION;
	  	  	Photon_Ptr->y = Photon_Ptr->y >> PRECISION_REDUCTION;
	  	  	Photon_Ptr->y = Photon_Ptr->y << PRECISION_REDUCTION;
	  	  	Photon_Ptr->z = Photon_Ptr->z >> PRECISION_REDUCTION;
	  	  	Photon_Ptr->z = Photon_Ptr->z << PRECISION_REDUCTION;
	  	  	Photon_Ptr->ux = Photon_Ptr->ux >> PRECISION_REDUCTION;
	  	  	Photon_Ptr->ux = Photon_Ptr->ux << PRECISION_REDUCTION;
	  	   	Photon_Ptr->uy = Photon_Ptr->uy >> PRECISION_REDUCTION;
	   	Photon_Ptr->uy = Photon_Ptr->uy << PRECISION_REDUCTION;
	  Hop(In_Ptr, Photon_Ptr, Out_Ptr);

	  Photon_Ptr->x = Photon_Ptr->x >> PRECISION_REDUCTION;
	  	Photon_Ptr->x = Photon_Ptr->x << PRECISION_REDUCTION;
	  	Photon_Ptr->y = Photon_Ptr->y >> PRECISION_REDUCTION;
	  	Photon_Ptr->y = Photon_Ptr->y << PRECISION_REDUCTION;
	  	Photon_Ptr->z = Photon_Ptr->z >> PRECISION_REDUCTION;
	  	Photon_Ptr->z = Photon_Ptr->z << PRECISION_REDUCTION;
	  	Photon_Ptr->ux = Photon_Ptr->ux >> PRECISION_REDUCTION;
	  	Photon_Ptr->ux = Photon_Ptr->ux << PRECISION_REDUCTION;
	   	Photon_Ptr->uy = Photon_Ptr->uy >> PRECISION_REDUCTION;
	   	Photon_Ptr->uy = Photon_Ptr->uy << PRECISION_REDUCTION;
	  	Photon_Ptr->uz = Photon_Ptr->uz >> PRECISION_REDUCTION;
		Photon_Ptr->uz = Photon_Ptr->uz << PRECISION_REDUCTION;


	  Drop(In_Ptr, Photon_Ptr, Out_Ptr);
	  Photon_Ptr->x = Photon_Ptr->x >> PRECISION_REDUCTION;
	  	  	Photon_Ptr->x = Photon_Ptr->x << PRECISION_REDUCTION;
	  	  	Photon_Ptr->y = Photon_Ptr->y >> PRECISION_REDUCTION;
	  	  	Photon_Ptr->y = Photon_Ptr->y << PRECISION_REDUCTION;
	  	  	Photon_Ptr->z = Photon_Ptr->z >> PRECISION_REDUCTION;
	  	Photon_Ptr->z = Photon_Ptr->z << PRECISION_REDUCTION;
	  	Photon_Ptr->ux = Photon_Ptr->ux >> PRECISION_REDUCTION;
			  	Photon_Ptr->ux = Photon_Ptr->ux << PRECISION_REDUCTION;
			   	Photon_Ptr->uy = Photon_Ptr->uy >> PRECISION_REDUCTION;
	   	Photon_Ptr->uy = Photon_Ptr->uy << PRECISION_REDUCTION;
	  Spin(In_Ptr->layerspecs[Photon_Ptr->layer].g,
		Photon_Ptr);
		Photon_Ptr->x = Photon_Ptr->x >> PRECISION_REDUCTION;
			  	Photon_Ptr->x = Photon_Ptr->x << PRECISION_REDUCTION;
			  	Photon_Ptr->y = Photon_Ptr->y >> PRECISION_REDUCTION;
			  	Photon_Ptr->y = Photon_Ptr->y << PRECISION_REDUCTION;
			  	Photon_Ptr->z = Photon_Ptr->z >> PRECISION_REDUCTION;
	  	Photon_Ptr->z = Photon_Ptr->z << PRECISION_REDUCTION;
	  	Photon_Ptr->ux = Photon_Ptr->ux >> PRECISION_REDUCTION;
			  	Photon_Ptr->ux = Photon_Ptr->ux << PRECISION_REDUCTION;
			   	Photon_Ptr->uy = Photon_Ptr->uy >> PRECISION_REDUCTION;
	   	Photon_Ptr->uy = Photon_Ptr->uy << PRECISION_REDUCTION;

  }


}

/***********************************************************
 *	The photon weight is small, and the photon packet tries
 *	to survive a roulette.
 ****/
void Roulette(PhotonStruct * Photon_Ptr)
{
  if(Photon_Ptr->w == 0.0)
    Photon_Ptr->dead = 1;
  else if(RandomNum() < CHANCE) /* survived the roulette.*/
    Photon_Ptr->w /= CHANCE;
  else
    Photon_Ptr->dead = 1;
}




/***********************************************************
 ****/
void HopDropSpin(InputStruct  *  In_Ptr,
				 PhotonStruct *  Photon_Ptr,
				 OutStruct    *  Out_Ptr)
{


  HopDropSpinInTissue(In_Ptr, Photon_Ptr, Out_Ptr);

  if( Photon_Ptr->w < In_Ptr->Wth && !Photon_Ptr->dead)
    Roulette(Photon_Ptr);
}



/***********************************************************
 *	Compute the Fresnel reflectance.
 *
 *	Make sure that the cosine of the incident angle a1
 *	is positive, and the case when the angle is greater
 *	than the critical angle is ruled out.
 *
 * 	Avoid trigonometric function operations as much as
 *	possible, because they are computation-intensive.
 ****/


void Calc_down_Fresnel(	int 				layer,
					int 				fres_index,
					InputStruct 	*	In_Ptr,
					int 			**	rFres_Ptr)
{

  double n1 = In_Ptr->layerspecs[layer+1].n;				/* incident refractive index.*/
  double n2 = In_Ptr->layerspecs[layer+2].n;			/* transmit refractive index.*/

  double ca1 =  (double)fres_index/NUM_FRESNELS;		/*uz*/



  double *ca2_Ptr;										/*new uz if photon goes down a layer*/
  double r;

  ca2_Ptr = (double*)malloc(sizeof(double));

  if(n1==n2) {			  	/** matched boundary. **/
    *ca2_Ptr = ca1;
    r = 0.0;
  }
  else if(ca1>COSZERO) {	/** normal incident. **/
    *ca2_Ptr = ca1;
    r = (n2-n1)/(n2+n1);
    r *= r;
  }
  else if(ca1<COS90D)  {	/** very slant. **/
    *ca2_Ptr = 0.0;
    r = 1.0;
  }
  else  {			  		/** general. **/
    double sa1, sa2;
	  /* sine of the incident and transmission angles. */
    double ca2;

    sa1 = sqrt(1-ca1*ca1);
    sa2 = n1*sa1/n2;
    if(sa2>=1.0) {
	  /* double check for total internal reflection. */
      *ca2_Ptr = 0.0;
      r = 1.0;
    }
    else  {
      double cap, cam;	/* cosines of the sum ap or */
						/* difference am of the two */
						/* angles. ap = a1+a2 */
						/* am = a1 - a2. */
      double sap, sam;	/* sines. */

      *ca2_Ptr = ca2 = sqrt(1-sa2*sa2);

      cap = ca1*ca2 - sa1*sa2; /* c+ = cc - ss. */
      cam = ca1*ca2 + sa1*sa2; /* c- = cc + ss. */
      sap = sa1*ca2 + ca1*sa2; /* s+ = sc + cs. */
      sam = sa1*ca2 - ca1*sa2; /* s- = sc - cs. */
      r = 0.5*sam*sam*(cam*cam+cap*cap)/(sap*sap*cam*cam);
		/* rearranged for speed. */
    }
  }
  rFres_Ptr[layer][fres_index] = (int)(r*INTMAX);

}

/***********************************************************
 *	Compute the Fresnel reflectance.
 *
 *	Make sure that the cosine of the incident angle a1
 *	is positive, and the case when the angle is greater
 *	than the critical angle is ruled out.
 *
 * 	Avoid trigonometric function operations as much as
 *	possible, because they are computation-intensive.
 ****/


void Calc_up_Fresnel(	int 				layer,
					int 				fres_index,
					InputStruct 	*	In_Ptr,
					int 			**	rFres_Ptr)
{

  double n1 = In_Ptr->layerspecs[layer+1].n;				/* incident refractive index.*/
  double n2 = In_Ptr->layerspecs[layer].n;				/* transmit refractive index.*/

  double ca1 =  (double)fres_index/NUM_FRESNELS;		/*uz*/


  double *ca2_Ptr;										/*new uz if photon goes down a layer*/
  double r;
  ca2_Ptr = (double*)malloc(sizeof(double));

  if(n1==n2) {			  	/** matched boundary. **/
    *ca2_Ptr = ca1;
    r = 0.0;
  }
  else if(ca1>COSZERO) {	/** normal incident. **/
    *ca2_Ptr = ca1;
    r = (n2-n1)/(n2+n1);
    r *= r;
  }
  else if(ca1<COS90D)  {	/** very slant. **/
    *ca2_Ptr = 0.0;
    r = 1.0;
  }
  else  {			  		/** general. **/
    double sa1, sa2;
	  /* sine of the incident and transmission angles. */
    double ca2;

    sa1 = sqrt(1-ca1*ca1);
    sa2 = n1*sa1/n2;
    if(sa2>=1.0) {
	  /* double check for total internal reflection. */
      *ca2_Ptr = 0.0;
      r = 1.0;
    }
    else  {
      double cap, cam;	/* cosines of the sum ap or */
						/* difference am of the two */
						/* angles. ap = a1+a2 */
						/* am = a1 - a2. */
      double sap, sam;	/* sines. */

      *ca2_Ptr = ca2 = sqrt(1-sa2*sa2);

      cap = ca1*ca2 - sa1*sa2; /* c+ = cc - ss. */
      cam = ca1*ca2 + sa1*sa2; /* c- = cc + ss. */
      sap = sa1*ca2 + ca1*sa2; /* s+ = sc + cs. */
      sam = sa1*ca2 - ca1*sa2; /* s- = sc - cs. */
      r = 0.5*sam*sam*(cam*cam+cap*cap)/(sap*sap*cam*cam);
		/* rearranged for speed. */
    }
  }
  rFres_Ptr[layer][fres_index] = (int)(r*INTMAX);

}

/***********************************************************
 ****/

void Compute_Fresnel(	int 				num_layers,
						InputStruct		*	In_Ptr,
						int 			**	down_rFres_Ptr,
						int 			**	up_rFres_Ptr
						)
{
	int i,j;

	/*initialize all values in fresnel LUT*/
	for (i=0; i<num_layers; i++) {
		for (j=0; j<NUM_FRESNELS; j++) {
			Calc_down_Fresnel(i, j, In_Ptr, down_rFres_Ptr);
			Calc_up_Fresnel(i, j, In_Ptr, up_rFres_Ptr);
		}
	}
}

/***********************************************************
 ****/

void Calc_Trig_Vals(	int					i,
						int					j,
						InputStruct		*	In_Ptr,
						TrigStruct		**	Trig_Ptr)
{
	double rnd = (double)j/NUM_TRIG_ELS;
	int layer = i;
	double g = In_Ptr->layerspecs[i+1].g;
	double cost, sint, cosp, sinp;


	cosp = cos(2*PI*rnd);
	if(2*rnd*PI<PI)
	    sinp = sqrt(1.0 - cosp*cosp);
		  /* sqrt() is faster than sin(). */
	else
    	sinp = - sqrt(1.0 - cosp*cosp);




	if(g == 0.0)
	    cost = 2*rnd -1;
	else {
	    double temp = (1-g*g)/(1-g+2*g*rnd);
	    cost = (1+g*g - temp*temp)/(2*g);
		if(cost < -1) cost = -1;
		else if(cost > 1) cost = 1;
	  }
	sint = sqrt(1-cost*cost);

	/*store results in constants*/
	Constants.trigVals[layer][j].cost = (int)(cost*INTMAX);
	Constants.trigVals[layer][j].sint = (int)(sint*INTMAX);
	Constants.trigVals[layer][j].cosp = (int)(cosp*INTMAX);
	Constants.trigVals[layer][j].sinp = (int)(sinp*INTMAX);
}

/***********************************************************
 ****/
void Compute_Trig_Vals( int					num_layers,
						InputStruct		*	In_Ptr,
						TrigStruct		**	Trig_Ptr)
{
	int i, j;

	/*initialize all values in trig LUT*/
	for (i=0; i<num_layers; i++) {
		for(j=0; j<NUM_TRIG_ELS; j++) {
			Calc_Trig_Vals(i, j, In_Ptr, Trig_Ptr);
		}
	}
}


/***********************************************************
*
*  Initialize system-wide constants (globals).  These constants
*  will be used to avoid floating-point calculations, and
*  include look-up tables, and physical constants
 ****/
 ConstStruct InitConsts(InputStruct		* In_Ptr) {

	/*Variable renaming*/
	LayerStruct *Layerspecs_Ptr = In_Ptr->layerspecs;
	int num_layers = In_Ptr->num_layers;
	double maxradius = MAXRADIUS(In_Ptr);
	double maxdepth = MAXDEPTH(In_Ptr);
	double mut, mua, mus;
	double weightFraction;

	int i, j;
	long long temp;
	double temp2;
	unsigned int tempINT;

	/*memory allocation*/
	Constants.OneOverMut			= (int*)malloc((1+num_layers)*sizeof(int));
	Constants.down_rFresnel			= (int**)malloc((1+num_layers)*sizeof(int*));
	Constants.up_rFresnel			= (int**)malloc((1+num_layers)*sizeof(int*));
	Constants.downCritAngle			= (int*)malloc((1+num_layers)*sizeof(int));
	Constants.upCritAngle			= (int*)malloc((1+num_layers)*sizeof(int));
	Constants.trigVals				= (TrigStruct**)malloc((num_layers)*sizeof(TrigStruct*));
	Constants.n						= (int*)malloc((2+num_layers)*sizeof(int));
	Constants.up_niOverNt			= (int*)malloc((1+num_layers)*sizeof(int));
	Constants.down_niOverNt			= (int*)malloc((1+num_layers)*sizeof(int));
	Constants.up_niOverNt_2			= (long long*)malloc((1+num_layers)*sizeof(long long));
	Constants.down_niOverNt_2		= (long long*)malloc((1+num_layers)*sizeof(long long));
	Constants.Mut					= (int*)malloc((1+num_layers)*sizeof(int));
	Constants.mus					= (int*)malloc((1+num_layers)*sizeof(int));
	Constants.mua					= (int*)malloc((1+num_layers)*sizeof(int));
	Constants.z0					= (int*)malloc((1+num_layers)*sizeof(int));
	Constants.z1					= (int*)malloc((1+num_layers)*sizeof(int));
	Constants.OneOver_MutMaxrad		= (int*)malloc((1+num_layers)*sizeof(int));
	Constants.OneOver_MutMaxdep		= (int*)malloc((1+num_layers)*sizeof(int));
	Constants.muaFraction			= (int*)malloc((1+num_layers)*sizeof(int));

	for (i=0; i<5; i++) {
		Constants.down_rFresnel[i]		= (int*)malloc(NUM_FRESNELS*sizeof(int));
		for (j=0; j<NUM_FRESNELS; j++)
			Constants.down_rFresnel[i][j] = 0;
		Constants.up_rFresnel[i]		= (int*)malloc(NUM_FRESNELS*sizeof(int));
		for (j=0; j<NUM_FRESNELS; j++)
			Constants.up_rFresnel[i][j] = 0;
		Constants.trigVals[i]			= (TrigStruct*)malloc(NUM_TRIG_ELS*sizeof(TrigStruct));
		for (j=0; j<NUM_TRIG_ELS; j++) {
			Constants.trigVals[i][j].cost = 0;
			Constants.trigVals[i][j].sint = 0;
			Constants.trigVals[i][j].cosp = 0;
			Constants.trigVals[i][j].sinp = 0;
		}
	}

	for(i=0; i<num_layers; i++) {
		if(Layerspecs_Ptr[i+1].n > Layerspecs_Ptr[i+2].n)
			/*critical angle: given by the physics of the problem, it is given by:
			critical angle = inverse sin(n2/n1) where n2 = refractive index of transmission tissue
			n1 = refractive index of incident tissue*/
			Constants.downCritAngle[i]	= (int)( cos(asin(Layerspecs_Ptr[i+2].n/Layerspecs_Ptr[i+1].n))*INTMAX);
		else
			Constants.downCritAngle[i] = 0;
		if(Layerspecs_Ptr[i+1].n > Layerspecs_Ptr[i].n)
			Constants.upCritAngle[i]	= (int)( cos(asin(Layerspecs_Ptr[i].n/Layerspecs_Ptr[i+1].n))*INTMAX);
		else
			Constants.upCritAngle[i]	= 0;
	}

	Compute_Fresnel(num_layers, In_Ptr, Constants.down_rFresnel, Constants.up_rFresnel);
	Compute_Trig_Vals(num_layers, In_Ptr, Constants.trigVals);



	/*Constants.Mut is a value between 0 and 1, scaled by INTMAX.  Any multiplications by
	Constants.Mut should be shifted by the appropriate shifting value, calculated here as well*/
	for (i=0; i<=num_layers; i++) {
		mut = (Layerspecs_Ptr[i].mua + Layerspecs_Ptr[i].mus);
		if(mut > 1<<MUTMAX_BITS)
			Constants.Mut[i] = INTMAX;
		else
			Constants.Mut[i] = (int)(mut/(1<<MUTMAX_BITS)*INTMAX);


	}

	/*Constants.Mua and Constants.Mus is a value between 0 and 1, scaled by INTMAX.  Any multiplications by
	either should be shifted by the appropriate shifting value, calculated here as well*/
	for (i=0; i<=num_layers; i++) {
		mua = Layerspecs_Ptr[i].mua;
		mus = Layerspecs_Ptr[i].mus;
		assert(mua <= 1<<MUTMAX_BITS);
		assert(mus <= 1<<MUTMAX_BITS);

		Constants.mua[i] = (int)(mua/(1<<MUTMAX_BITS)*INTMAX);
		Constants.mus[i] = (int)(mus/(1<<MUTMAX_BITS)*INTMAX);
	}

	//Real.mci must match hw_parameters.h
	Constants.z0[i] = 0;
	Constants.z1[i] = 0;
	/* layer information is from 0 to maxdepth, Otherwise die hard */
	for (i=1; i<=num_layers; i++) {
		assert(Layerspecs_Ptr[i].z0 <= maxdepth && Layerspecs_Ptr[i].z1 <= maxdepth);
		Constants.z0[i] = INTDEPTH(Layerspecs_Ptr[i].z0, maxdepth);
		Constants.z1[i] = INTDEPTH(Layerspecs_Ptr[i].z1, maxdepth);
	}


	/*Initialize 1/ut values for each layer*/
	for(i=1; i<=num_layers; i++) {
		Constants.OneOverMut[i]	= (int)(1/(Layerspecs_Ptr[i].mua + Layerspecs_Ptr[i].mus)*INTMAX);
	}
	for(i=0; i<=num_layers+1; i++) {
			Constants.n[i]	= (int)(Layerspecs_Ptr[i].n*INTMAX/MAX_N);
	}

	for(i=1; i<=num_layers; i++) {
		Constants.down_niOverNt[i] = (int)( (double)Constants.n[i]/(double)Constants.n[i+1]*(double)INTMAX/(double)MAX_N);
		Constants.down_niOverNt_2[i] = (long long)Constants.down_niOverNt[i]*(long long)Constants.down_niOverNt[i];
		Constants.up_niOverNt[i] = (int)( (double)Constants.n[i]/(double)Constants.n[i-1]*(double)INTMAX/(double)MAX_N);
		Constants.up_niOverNt_2[i] = (long long)Constants.up_niOverNt[i]*(long long)Constants.up_niOverNt[i];

	}

	/*Initialize 1/ut values for each layer*/
	for(i=1; i<=num_layers; i++) {
		Constants.OneOverMut[i]	= (int)(1/(Layerspecs_Ptr[i].mua + Layerspecs_Ptr[i].mus)*INTMAX);

		if(1/((Layerspecs_Ptr[i].mua + Layerspecs_Ptr[i].mus)*maxradius) > 1)
			Constants.OneOver_MutMaxrad[i] = INTMAX;
		else
			Constants.OneOver_MutMaxrad[i] = (int)(1/((Layerspecs_Ptr[i].mua + Layerspecs_Ptr[i].mus)*maxradius)*INTMAX);


		if(1/((Layerspecs_Ptr[i].mua + Layerspecs_Ptr[i].mus)*maxdepth) > 1)
			Constants.OneOver_MutMaxdep[i] = INTMAX;
		else
			Constants.OneOver_MutMaxdep[i] = (int)(1/((Layerspecs_Ptr[i].mua + Layerspecs_Ptr[i].mus)*maxdepth)*INTMAX);

	}

	for(i=0; i<6; i++) {
		mua=(double)Constants.mua[i];
		mus=(double)Constants.mus[i];
		temp2= mua/(mua+mus);

		tempINT=(unsigned int)(temp2 * pow(2, 32));
		Constants.muaFraction[i]=tempINT;
	}


	Constants.logIntmax = (int)(log(INTMAX)/32*INTMAX);
	Constants.maxDepth	= (int)(maxdepth*INTMAX/MAX_DIMENSION_SIZE);
	Constants.maxRadius	= (int)(maxradius*INTMAX/MAX_DIMENSION_SIZE);
	Constants.totalPhotons = (int)(In_Ptr->num_photons);

	temp = (long long)(maxdepth / maxradius * INTMAX) / MAX_DIMENSION_SIZE;
	Constants.maxDepth_over_maxRadius = (int) temp;

	Constants.dr = In_Ptr->dr;
	Constants.dz = In_Ptr->dz;


	weightFraction = (Layerspecs_Ptr[0].n-Layerspecs_Ptr[1].n)*(Layerspecs_Ptr[0].n-Layerspecs_Ptr[1].n) /
                     ( (Layerspecs_Ptr[0].n+Layerspecs_Ptr[1].n)*(Layerspecs_Ptr[0].n+Layerspecs_Ptr[1].n) );

	weightFraction *= WSCALE;
	Constants.initialWeight = (int)(WSCALE - weightFraction);

	return(Constants);

}
