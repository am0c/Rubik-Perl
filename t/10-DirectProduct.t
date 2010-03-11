use strict;
use warnings;
use Test::More;
use CM::Group::Sym;
use CM::Group::Dihedral;
use CM::Group::ModuloMultiplication;
use CM::Group::Product;
use Data::Dumper;

my $g = CM::Group::Sym->new({n=> 3});
my $d = CM::Group::Dihedral->new({n=> 4});

my $p = CM::Group::Product->new({n=>1,groupG=>$g,groupH=>$d}); # the n here doesn't matter since it won't be used as the order
							       # will depend solely on groupG and groupH


$p->compute;


ok(~~@{$p->elements}== (~~@{$g->elements})*(~~@{$d->elements}),'number of elements checked');

#print $r->stringify;

my $p1 =CM::Group::Product->new({n=>1,groupG=>$p,groupH=>$d});

$p1->compute;


ok(~~@{$p1->elements}== (~~@{$p->elements})*(~~@{$d->elements}),'number of elements checked 2');
ok(~~@{$p1->elements}== (~~@{$g->elements})*(~~@{$g->elements})*(~~@{$d->elements}),'number of elements checked 3');

done_testing();

