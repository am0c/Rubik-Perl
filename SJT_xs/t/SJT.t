# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl SJT.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Devel::Peek;
use Data::Dumper;
use Test::More tests => 1;
BEGIN {
	use_ok('SJT'); 
	my $s1 = SJT->new(4);
	Dump($s1);
	print "HERE be 3:".$s1->get(1)."\n";
	print "\n";
};


#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

