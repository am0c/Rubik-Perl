package TestType;
use Moose;
extends 'CM::Tuple';

package main;
use strict;
use warnings;
use Test::More;
#use CM::Permutation;
use Data::Dumper;


my $p1 = TestType->new({
		first => 12,#CM::Permutation->new(3,1,2),
		second=> 8,
	});

my $p2 = TestType->new({
		first => 2,#CM::Permutation->new(1,3,2),
		second=> 9,
	});


isa_ok($p1,'TestType');
isa_ok($p2,'TestType');
my $r = $p1 * $p2;
isa_ok($r,'TestType');
is($r->first,24,'first arged multipied ok');
is($r->second,72,'second arged multipied ok');
is("$p1","[12|8]","stringify tested");

done_testing();
