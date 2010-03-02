#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#include <string.h>

/*
 * Mon 01 Mar 2010 10:09:22 PM EST
 * 
 * REM:
 *
 * stash - symbol table hash
 * AV - array variable
 * HV - hash variable
 * SV - scalar variable
 *
 *
 * References
 *
 * Book: Extending and embedding Perl , perldoc: perlxs,perlapi,perlxstut
 *
 * pages 101-105 -> Tied scalar and objects
 *
 * pages 106-107 -> Arrays
 *
 * pages 107-111 -> Hashes
 *
 *
 *
 * Functions
 *
 * pages 152 -> Array functions  av_* and *_av
 *
 *
 *
 * NOTE: speedups can be made if I take an attribute of the object and make it accessible only to XS code and store in it the
 * data I need to persist and compute in normal C data structures inside it. only when "rendering" will SV data structures be created.
 *
 */


//used for debugging
#define print_sv(w)   printf("SV at line __LINE__ :%x\n",w);
#define permut(i) g__(self,i,"permutation")
#define direct(i) g__(self,i,"direction")
#define p(x) ( x + SvUV(direct(x)) )

SV* g__(SV* self,int index,char* key) { // used for get_permut and get_direct to get elements of permutation and direction attributes(arefs)
		AV* array;
		SV* hv = self;
		if(sv_isobject(hv)) {
			//printf("self is object,moving on...\n");
		} else {
			printf("SJT::get was expecting self to be an object");
		};

		HV* q = (HV *)SvRV(hv);

		array = SvRV(*hv_fetch(q,key,strlen(key),FALSE));

		if(array==NULL) {
			printf("array not found in self...\n");
			exit(-1);
		}else {
			//printf("array found in self %X\n",array);
		};

		SV** res = av_fetch(array,index,FALSE);
		if(res==NULL) {
			printf("item not found in array...\n");
			exit(-1);
		}else {
			//printf("also found item in array at: %X\n",res);
		};

		//print_sv(*res);


		SV *ret=*res;
		SvREFCNT_inc(ret); //increase the reference count of this because it suffered premature deallocation

		return ret;
}

// UV works with signed and unsigned integers, IV just with signed

void xchg__(SV* self,SV* i,SV* j) {
		printf("in xchg__\n");

		UV ival = SvUV(i);
		UV jval = SvUV(j);

		sv_setuv(i,jval);
		sv_setuv(j,ival);
}

void xchg2__(SV* self,SV* i,SV* j) {
		xchg__(	self,permut(i),permut(j) );
		xchg__(	self,direct(i),direct(j) );
}


// get n attribute of class

UV getn(SV* self) {
	SV* hv = self;
	HV* q = (HV *)SvRV(hv);
	SV* result = *hv_fetch(q,"n",1,FALSE);

	UV ret = SvUV(result);
	return ret;
}



// dereference to UV

UV df(SV* param) { 
	return SvUV(param);
}


// checks if at pos there is a mobile integer
bool mobile(SV *self,int pos) {
	if(p(pos) > getn(self) || p(pos)==0)
		return 0;
	return df(permut(p(pos))) < df(permut(pos));
}

// gets the biggest mobile integer if any

int emobile(SV *self) {
	int maxpos = 0;
	int max    = 0;
	int n = getn(self);
	int i;
	for(i=1;i<=n;i++) {
		if(!mobile(self,i))
			continue;
		int perm = df(permut(i));
		if(perm > max) {
			maxpos = i;
			max    = perm;
			if(max == n) {
				return maxpos;
			}
		};
	}
}

// make permutation arrayref the next permutation
/*
int nextperm(SV *self) {
	int k = emobile(self);
	int max_mob = df(permut(k));

	if(k==0)
		return 0;
	xchg(k,p(k));

	for(int i=1;i<=n;i++){
		if(permut[i]>max_mob)
			//changes direction of mobile integer
			direct[i]*=-1;
	};
}
*/


MODULE = SJT		PACKAGE = SJT		






#// get_permut, gets the SV* at index index in the permutation arrayref of the object

SV* get_permut(self,index)
	SV* self
	int index
	CODE:
		SV *ret=permut(index);
		//T_PTROBJ could be used to store pointers to userdefined data structures
		RETVAL=ret;

	OUTPUT:
		RETVAL

#// get_direct, gets the SV* at index index in the direction arrayref of the object

SV* get_direct(self,index)
	SV* self
	int index
	CODE:
		SV *ret=g__(self,index,"direction");
		#direct(index);
		//T_PTROBJ could be used to store pointers to userdefined data structures
		RETVAL=ret;
	OUTPUT:
		RETVAL

#//dereference a SV* to a SvIV (integer)

UV deref(self,adr)
	SV* self
	SV* adr
	CODE:
		#IV a = 1;
		UV a = SvUV(adr);
		RETVAL = a;
	OUTPUT:
		RETVAL


#// xchg swaps 2 entries of a arrayref filled with scalars(preferably numbers)



IV xchg(self,i,j)
	SV* i
	SV* j
	SV* self
	CODE:
		xchg__(self,i,j);
		RETVAL = 1;
	OUTPUT:
		RETVAL


#// xchg2 is used to swap 2 positions in both permutation and direction arrayrefs


IV
xchg2(self,i,j)
	int i
	int j
	SV* self
	CODE:
		xchg2__(self,i,j);

		RETVAL = 1;
	OUTPUT:
		RETVAL


UV
get_n(self)
	SV* self
	CODE:
		UV result = getn(self);
		RETVAL = result;
	OUTPUT:
		RETVAL
