use strict;
use warnings;
use Test::More;
use CM::Group::Sym;
use CM::Permutation;

my $G = CM::Group::Sym->new({n=>4});
$G->compute_elements()->();
my $H = CM::Group::Sym->new({n=>2});

$H->elements([CM::Permutation->new(1,2,3,4),CM::Permutation->new(2,3,1,4),CM::Permutation->new(3,1,2,4)]);



my @elems_factor = @{$G->factor($H)};
ok(@elems_factor==( ~~@{$G->elements} ) / ( ~~@{$H->elements} ), "|G/H|=[G:H]=|G|/|H|");

#print join("\n",map { 
	  #join(";",@$_);
	#} @elems_factor);

done_testing();
