use strict;
use warnings;

use lib './blib/arch/auto/SJT'; # <-- where .so is located
use lib './lib';

BEGIN {
	use SJT;
	my $s1 = SJT->new(4); # 4 permutations


	print "asgasg";

	my $x;
	while(my $x = $s1->next_perm_obj) {
		<>;
		print "stuff\n";
		print "$x\n";
	}
}
