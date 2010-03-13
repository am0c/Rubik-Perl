use CM::Morphism;
use CM::Group::Sym;
use Test::More;
use strict;
use warnings;

my $G = CM::Group::Sym->new({n=>4});
$G->compute_elements()->();

my $H = CM::Group::Sym->new({n=>2});
$H->elements([
	CM::Permutation->new(1,2,3,4),
	CM::Permutation->new(2,3,1,4),
	CM::Permutation->new(3,1,2,4)
]);





my $f = CM::Morphism->new({
		f        => sub {
			my ($x) = @_;
		},
		domain   => $G,
		codomain => $H,
});


done_testing;
