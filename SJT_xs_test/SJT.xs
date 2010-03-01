#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"


int test[10] = {10,9,8,7,6,5,4,3,2,1};



MODULE = SJT		PACKAGE = SJT		


int get(self,index)
	SV* self
	int index
	CODE:
		RETVAL = self->test[index];
	OUTPUT:
		RETVAL

void
set(self,index,value)
	SV* self
	int index;
	int value;
	CODE:
		test[index] = self->value;
	OUTPUT:
		index

