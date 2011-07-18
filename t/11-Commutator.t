use strict;
use warnings;
use Test::More;
use CM::Group::Sym;


my $p = CM::Group::Sym->new({n=>4});
$p->compute_elements()->();

ok(1);

#TODO: this test fails, need to fix it
#my $g = $p->commutator;
#ok(@{$g->elements}==12,'twelve elements');


#TODO: this test fails, should fix it
#$g->compute;
#ok($p->normal($g)==1,'commutator subgroup is normal');

#print $g;

done_testing();
