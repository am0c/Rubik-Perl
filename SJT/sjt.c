// Stefan Petrea
//
//
//
// Steinhaus - Johnson - Trotter C implementation
#include <stdio.h>
#define SIZE 50
//position to which direct(x) indicates

#define p(x) (x + (direct[x] ? -1))
#define LEFT	-1
#define RIGHT	+1
int permut[SIZE+1];//permutation
int direct[SIZE+1];//direction
int n;

void set_n(int N) {
	n=N;
}

void init() {
	for(int i=1;i<SIZE+1;i++)
		permut[i]=i;
	memset(direct,SIZE+1,LEFT);
}

void main() {
}


int mobile(int pos) {
	if(p(pos) > n || p(pos)==0)
		return 0;
	return permut[p(pos)] < permut[pos];
}

int emobile() {
	int maxpos = 0;
	int max    = 0;
	for(int i=1;i<=n;i++) {
		if(!mobile(i))
			continue;
		if(permut[i] > max) {
			maxpos = i;
			max    = permut[i];
			if(max==n) {
				return maxpos;
			}
		};
	}
}


int xchg(int i, int j) {
	int t     = permut[i];
	permut[i] = permut[j];
	permut[j] = t;

	int t1    = direct[i];
	direct[i] = direct[j];
	direct[j] = t1;
}

void print_perm {
	for(int i=1;i<=n;i++) {
		printf(
				"%c ",
				(direct[i] ==1?'>':'<')
		      );
	};
	printf("\n");
}


// will return 0 if there are no more permutations
// will return 1 if there is one more and it has been computed in perm
int next_perm() {
	int k = emobile();
	int max_mob = permut[k];

	if(k==0)
		return 0;
	xchg(k,p(k));

	for(int i=1;i<=n;i++){
		if(permut[i]>max_mob)
			//changes direction of mobile integer
			direct[i]*=-1;
	};
}

