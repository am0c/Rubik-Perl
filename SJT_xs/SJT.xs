#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

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
 */


#define print_sv(w)   printf("SV at line __LINE__ :%x\n",w);


#// get_permut, gets the SV* at index index in the permutation arrayref of the object

MODULE = SJT		PACKAGE = SJT		

SV* get_permut(self,index)
	SV* self
	int index
	CODE:
		char* key = "permutation";
		AV* array;
		SV* hv = self;
		if(sv_isobject(hv)) {
			printf("self is object,moving on...\n");
		} else {
			printf("SJT::get was expecting self to be an object");
		};

		HV* q = (HV *)SvRV(hv);

		array = SvRV(*hv_fetch(q,"permutation",11,FALSE));

		if(array==NULL) {
			printf("array not found in self...\n");
			exit(-1);
		}else {
			printf("array found in self %X\n",array);
		};

		SV** res = av_fetch(array,index,FALSE);
		if(res==NULL) {
			printf("item not found in array...\n");
			exit(-1);
		}else {
			printf("also found item in array at: %X\n",res);
		};

		print_sv(*res);


		SV *ret=*res;
		SvREFCNT_inc(ret); //increase the reference count of this because it suffered premature deallocation
		
		//T_PTROBJ could be used to store pointers to userdefined data structures
		RETVAL=ret;

	OUTPUT:
		RETVAL

#// get_direct, gets the SV* at index index in the direction arrayref of the object

SV* get_direct(self,index)
	SV* self
	int index
	CODE:
		char* key = "direction";
		AV* array;
		SV* hv = self;
		if(sv_isobject(hv)) {
			printf("self is object,moving on...\n");
		} else {
			printf("SJT::get was expecting self to be an object");
		};

		HV* q = (HV *)SvRV(hv);

		array = SvRV(*hv_fetch(q,"permutation",11,FALSE));

		if(array==NULL) {
			printf("array not found in self...\n");
			exit(-1);
		}else {
			printf("array found in self %X\n",array);
		};

		SV** res = av_fetch(array,index,FALSE);
		if(res==NULL) {
			printf("item not found in array...\n");
			exit(-1);
		}else {
			printf("also found item in array at: %X\n",res);
		};

		SV *ret=*res;
		SvREFCNT_inc(ret); //increase the reference count of this because it suffered premature deallocation
		
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
		IV ival = SvIV(i);
		IV jval = SvIV(j);
		sv_setiv(i,jval);
		sv_setiv(j,ival);

		RETVAL = 1;
	OUTPUT:
		RETVAL


#// xchg2 is used to swap 2 positions in both permutation and direction arrayrefs


IV
xchg2(self,i,j)
	SV* self
	int i
	int j
	CODE:
		xchg(self,get_permut(self,i),get_permut(self,j));
		xchg(self,get_direct(self,i),get_direct(self,j));
		RETVAL = 1;
	OUTPUT:
		RETVAL




IV
set(self,index,value)
	SV* self
	int index;
	int value;
	CODE:
		RETVAL = 1;
	OUTPUT:
		RETVAL
