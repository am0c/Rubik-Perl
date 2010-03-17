use Test::More;
use CM::Group::ModuloAddition;


# the inverse order is caused by unshift instead of push inside add_to_elements

my $g = CM::Group::ModuloAddition->new({n=>8});
$g->compute;

print $g->stringify;

ok(1,"dummy test");

done_testing();
