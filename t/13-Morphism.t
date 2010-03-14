use CM::Morphism;
use CM::Group::Sym;
use Test::More;
use strict;
use warnings;

my $G = CM::Group::Sym->new({n=>4});
$G->compute_elements()->();

my $f = CM::Morphism->new({
		f        => sub {
			my ($x) = @_;
			return $x;
		},
		domain   => $G,
		codomain => $G,
});

my $kerf = $f->kernel;
my $imf  = $f->image;

my $Gdiv_kerf = $G->factor($kerf);

ok( ~~@{$Gdiv_kerf} == ~~@{$imf->elements} , 
	"first isomorphism theorem respected in cardinality");



done_testing;
