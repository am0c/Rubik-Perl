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
#define p(x) ( x + df(direct(x)) )

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

// dereference to UV

IV df(SV* param) { 
	return SvIV(param);
}

// UV are unsigned ints and IV are signed ints

void xchg__(SV* self,SV* i,SV* j) {
		//printf("in xchg__\n");

		IV ival = df(i);
		IV jval = df(j);

		sv_setiv(i,jval);
		sv_setiv(j,ival);
}

void xchg2__(SV* self,SV* i,SV* j) {
		xchg__(	self,permut(i),permut(j) );
		xchg__(	self,direct(i),direct(j) );
}


// invert direction at position i

void invert_direct(SV* self,int i) {
		SV* adr = direct(i);
		IV val = df(adr);
		val*=-1;
		sv_setuv(adr,val);
}


// get n attribute of class

IV getn(SV* self) {
	SV* hv = self;
	HV* q = (HV *)SvRV(hv);
	SV* result = *hv_fetch(q,"n",1,FALSE);

	IV ret = SvIV(result);
	return ret;
}



// checks if at pos there is a mobile integer
int mobile(SV *self,int pos) {
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
	return maxpos;
}

// make permutation arrayref the next permutation
int nextperm(SV *self) {
	int k = emobile(self);
	int max_mob = df(permut(k));
	int n = getn(self);
	int i;

	//printf("mobile integer on position: %d with value:%d\n",k,max_mob);

	if(k==0)
		return 0;

	xchg2__(self,k,p(k)); // exchange positions k and p(k)

	//invert direction of mobile integers
	for(i=1;i<=n;i++)
		if(df(permut(i))>max_mob)
			invert_direct(self,i);
}


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

IV deref(self,adr)
	SV* self
	SV* adr
	CODE:
		#IV a = 1;
		IV a = SvIV(adr);
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


IV
get_n(self)
	SV* self
	CODE:
		IV result = getn(self);
		RETVAL = result;
	OUTPUT:
		RETVAL


IV
next_perm(self)
	SV* self
	CODE:
		RETVAL = nextperm(self);
	OUTPUT:
		RETVAL
