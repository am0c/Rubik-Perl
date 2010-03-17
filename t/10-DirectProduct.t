use strict;
use warnings;
use Test::More;
use CM::Group::Sym;
use CM::Group::Dihedral;
use CM::Group::ModuloMultiplication;
use CM::Group::ModuloAddition;
use CM::Group::Product;
use CM::Permutation;
use Data::Dumper;
use Math::BigInt qw/blcm/;

my $g = CM::Group::Sym->new({n=> 3}); # S_3
my $z = CM::Group::ModuloAddition->new({n=> 4}); # Z_4
my $d = CM::Group::Dihedral->new({n=> 4});# D_4


# the n here doesn't matter since it won't be used as the order
# will depend solely on groupG and groupH
my $p = CM::Group::Product->new({n=>1,groupG=>$g,groupH=>$d});  # S_3 x D_4
my $zg = CM::Group::Product->new({n=>1,groupG=>$g,groupH=>$z}); # Z_3 x S_3
my $p1 =CM::Group::Product->new({n=>1,groupG=>$p,groupH=>$d});  # S_3 x D_4 x D_4


$p->compute_elements->();


ok($d->identity == CM::Permutation->new(1,2,3,4) , 'identity verified for dihedral group');

ok(~~@{$p->elements}== (~~@{$g->elements})*(~~@{$d->elements}),'number of elements checked'); 






$p1->compute_elements->();


ok(~~@{$p1->elements}== (~~@{$p->elements})*(~~@{$d->elements}),'number of elements checked 2'); # |S_3 x D_4 x D_4|=|S_3|*|D_4|^2= 384
ok(~~@{$p1->elements}== (~~@{$g->elements})*(~~@{$d->elements})*(~~@{$d->elements}),'number of elements checked 3');#same

goto SKIP_EM;


my $check=1;
for my $pelem (@{$p->elements}) {
	ok($pelem->order % $p->order , 'Lagrange verified for tuple element '."$pelem");
	ok($pelem**$pelem->order==$p->identity,"element order check$check");
	$check++;
}

SKIP_EM:


$zg->compute();
print $zg->stringify;




done_testing();
