use Test::More;
use CM::Group::ModuloMultiplication;

my $g = CM::Group::ModuloMultiplication->new({n=>8});
$g->compute;

print $g->stringify;

ok(1,"dummy test");

done_testing();
