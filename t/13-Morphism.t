use CM::Morphism;
use CM::Group::Sym;
use CM::Group::ModuloAddition;
use Test::More;
use strict;
use warnings;

# there are of course big finite groups and infinite groups
# and all the code here won't work on those, but for the small ones
# we can write these tests.


my $G = CM::Group::Sym->new({n=>4});
$G->compute_elements()->();

goto SKIP_TO_HZ;


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



# proving there is a morphism so that    (Z_4,+) ~ <(2,3,4,1)>
#                                        $Z      ~ $H
SKIP_TO_HZ:

my $Hgen = CM::Permutation->new(2,3,4,1);

my $Z = CM::Group::ModuloAddition->new({n=> 4}); # Z_4
my $H = $G->dimino($Hgen);


ok(@{$H->elements}==4,"H has 4 elements");
#$Z->compute_elements->();
$Z->compute();


my $m = CM::Morphism->new({
		f        => sub {
			my ($x) = @_;
			#use Data::Dumper;
			#print Dumper $x;
			#print "$x"; exit;
			return $Hgen ** ("$x");
		},
		domain   => $Z,
		codomain => $H,
});

ok($m->prove,'Z_4 and <(2,3,4,1)> are isomorphic');



done_testing;
