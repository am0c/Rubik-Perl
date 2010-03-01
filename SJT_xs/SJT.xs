#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

/*
 *
 * REM:
 *
 * stash - symbol table hash
 * AV - array variable
 *
 *
 * References
 *
 * Extending and embedding Perl
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



MODULE = SJT		PACKAGE = SJT		


int get(self,index)
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

		array = *hv_fetch(q,"permutation",11,FALSE);

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

		
		
		IV a = SvIV(SvRV(*res));
		printf("right before return\n");
		RETVAL = a;//SvIV(*av_fetch(array,index,FALSE));

	OUTPUT:
		RETVAL

void
set(self,index,value)
	SV* self
	int index;
	int value;
	CODE:
	OUTPUT:
