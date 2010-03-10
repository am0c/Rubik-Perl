use strict;
use warnings;
use Test::More;
use CM::Group::Sym;
use CM::Group::Dihedral;
use CM::Group::ModuloMultiplication;
use Data::Dumper;

my $g = CM::Group::Sym->new({n=> 3});
my $d = CM::Group::Dihedral->new({n=> 4});

my $r = $g->group_product($d);
$r->compute_elements;

ok(~~@{$r->elements}== (~~@{$g->elements})*(~~@{$d->elements}),'number of elements checked');
#print Dumper $r;
print "Aaaaaaaaaa";

done_testing();
