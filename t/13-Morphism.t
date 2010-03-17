use CM::Morphism;
use CM::Group::Sym;
use Test::More;
use strict;
use warnings;

my $G = CM::Group::Sym->new({n=>4});
$G->compute_elements()->();


my $z = $G->elements->[5];# some random permutation

my $f = CM::Morphism->new({
		f        => sub {
			my ($x) = @_;
			return $x;
		},
		domain   => $G,
		codomain => $G,
});

my $h = CM::Morphism->new({
		f        => sub {
			my ($x) = @_;
			return $z**-1 * $x * $z;#conjugate $x with $some_perm
		},
		domain   => $G,
		codomain => $G,
});

my $j = $f*$h;

# the word "proved" here is somewhat abused, it actually means just "verified"..

my $kerf = $f->kernel;
my $kerh = $h->kernel;
my $kerj = $j->kernel;
my $imf  = $f->image;
my $imh  = $h->image;
my $imj  = $j->image;


my $Gdiv_kerf = $G->factor($kerf);
my $Gdiv_kerh = $G->factor($kerh);
my $Gdiv_kerj = $G->factor($kerj);

ok( ~~@{$Gdiv_kerf} == ~~@{$imf->elements} , 
	"first isomorphism theorem respected in cardinality");
ok( ~~@{$Gdiv_kerh} == ~~@{$imh->elements} , 
	"first isomorphism theorem yet another time");
ok( ~~@{$Gdiv_kerj} == ~~@{$imj->elements} , 
	"first isomorphism theorem verified yet another time");

ok($f->prove,"proved morphism f");
ok($h->prove,"proved morphism h");
ok($j->prove,"proved morphism j(that is f o h)");







done_testing;
