use lib './lib/';
use CM::Permutation::Cycle_Algorithm;
use Data::Dumper;
use Test::More 'no_plan';

my $p = CM::Permutation::Cycle_Algorithm->new(13,11,14,10,12,8,9,6,7,4,5,2,3,1);
$p->run;
#print $p->str_decomposed;
ok($p->str_decomposed eq '(13,3,14,1)*(11,5,12,2)*(10,4)*(8,6)*(9,7)', 'sample permutation decomposition worked out fine')
