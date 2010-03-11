use strict;
use warnings;
use Test::More;
use CM::Group::Sym;
use CM::Group::Dihedral;
use CM::Group::ModuloMultiplication;
use CM::Group::Product;
use CM::Permutation;
use Data::Dumper;
use Math::BigInt qw/blcm/;

my $g = CM::Group::Sym->new({n=> 3});
my $d = CM::Group::Dihedral->new({n=> 4});



my $p = CM::Group::Product->new({n=>1,groupG=>$g,groupH=>$d}); # the n here doesn't matter since it won't be used as the order
							       # will depend solely on groupG and groupH


$p->compute_elements;


ok($d->identity == CM::Permutation->new(1,2,3,4) , 'identity verified for dihedral group');

ok(~~@{$p->elements}== (~~@{$g->elements})*(~~@{$d->elements}),'number of elements checked');

#print $r->stringify;

my $p1 =CM::Group::Product->new({n=>1,groupG=>$p,groupH=>$d});

$p1->compute_elements;


ok(~~@{$p1->elements}== (~~@{$p->elements})*(~~@{$d->elements}),'number of elements checked 2');
ok(~~@{$p1->elements}== (~~@{$g->elements})*(~~@{$d->elements})*(~~@{$d->elements}),'number of elements checked 3');



my $check=1;
for my $pelem (@{$p->elements}) {
	ok($pelem->order % $p->order , 'Lagrange verified for tuple element '."$pelem");
	ok($pelem**$pelem->order==$p->identity,"element order check$check");
	$check++;
}




done_testing();
