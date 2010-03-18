use CM::Group::Sym;
use CM::Group::Product;
use CM::Group::ModuloAddition;
use CM::Permutation;
use lib './lib/';

my $g = CM::Group::Sym->new({n=> 3}); # S_3
my $z = CM::Group::ModuloAddition->new({n=> 4}); # Z_4

my $zg = CM::Group::Product->new({n=>1,groupG=>$g,groupH=>$z}); # Z_3 x S_3

$zg->compute();

print $zg->stringify;
$zg->draw_asciitable("table3.html");




