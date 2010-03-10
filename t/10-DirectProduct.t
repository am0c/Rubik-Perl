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

my $r = CM::Group::Product->new({n=>1,groupG=>$g,groupH=>$d}); # the n here doesn't matter since it won't be used as the order
							       # will depend solely on groupG and groupH


$r->compute->elements;


ok(~~@{$r->elements}== (~~@{$g->elements})*(~~@{$d->elements}),'number of elements checked');
$r->draw_asciitable("table_product.html");

done_testing();

