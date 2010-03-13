use strict;
use warnings;
use Test::More;
use CM::Group::Sym;


my $p = CM::Group::Sym->new({n=>4});
$p->compute_elements()->();

my $g = $p->commutator;

ok(@{$g->elements}==12,'twelve elements');

$g->compute;

ok($g->normal==1,'commutator subgroup is normal');

#print $g;

done_testing();
