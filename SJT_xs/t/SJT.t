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

	#Dump($s1);

	my $a = 123;
	my $b = 321;
	ok($s1->deref($a)==123,"deref() works fine");
	$s1->xchg($a,$b);

	ok($a==321 && $b==123,"xchg() works fine");

	ok($s1->get_permut(2)==2,"get_permut() and deref working fine");
	ok($s1->get_direct(2)==-1,"get_direct() and deref working fine");

	$s1->{direction}->[2]=3;
	$s1->{direction}->[3]=2;

	$s1->xchg2(2,3);#exchange position 2 and 3

	my @aref = @{$s1->{permutation}};
	ok(	$aref[0]==0&&
		$aref[1]==1&&
		$aref[2]==3&&
		$aref[3]==2&&
		$aref[4]==4,
		"checked permutation array after swap"
	);

	@aref = @{$s1->{direction}};

	ok(
		$aref[2]==2 && $aref[3]==3,
		"checked direction array after swap"
   	);

	$s1->{direction}->[2]=-1;
	$s1->{direction}->[3]=-1;

	$s1->xchg2(2,3);
	@aref = @{$s1->{direction}};

	ok( $aref[2]==-1 && $aref[3]==-1, "swapped negative numbers");



	ok($s1->get_n()==4,"get_n() works properly");


	my $s2 = SJT->new(3);
	
	my $run_perm_tests = 0;

	sub test_p {# test if permutation in $s2 is @p
		return unless $run_perm_tests;
		my (@p) = @_;
		my (@p1) = @{$s2->{permutation}};
		unshift(@p,0);

		ok(	$p[1]==$p1[1]&&
			$p[2]==$p1[2]&&
			$p[3]==$p1[3],
			"expected [@p] ; got [@p1]"
		);
	}

	test_p(1,2,3);
	$s2->print_perm;
	$s2->next_perm;
	test_p(1,3,2);
	$s2->print_perm;
	$s2->next_perm;
	test_p(3,1,2);
	$s2->print_perm;
	$s2->next_perm;
	test_p(3,2,1);
	$s2->print_perm;
	$s2->next_perm;
	test_p(2,3,1);
	$s2->print_perm;
	$s2->next_perm;
	test_p(2,1,3);
	$s2->print_perm;

	print "\n";
	done_testing();
};


