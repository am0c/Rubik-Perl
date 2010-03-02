# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl SJT.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Devel::Peek;
use Data::Dumper;
use Test::More 'no_plan';
BEGIN {
	use_ok('SJT'); 
	my $s1 = SJT->new(4); # 4 permutations

	my $a = 123;
	my $b = 321;
	ok($s1->deref($a)==123,"deref() works fine");
	$s1->xchg($a,$b);
	ok($a==321 && $b==123,"xchg() works fine");

	ok($s1->deref($s1->get_permut(2))==2,"get_permut() and deref working fine");

	print "\n";
	done_testing();
};


#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

