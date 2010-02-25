use Test::More;
use CM::Group::Dihedral;

my $g = CM::Group::Dihedral->new({n=>5});

$g->compute_elements();

$g->compute;

ok("$g" eq
qq{ 1  5  4  3  2  9  8  7  6 10
 2  1  5  4  3  8  7  6 10  9
 3  2  1  5  4  7  6 10  9  8
 4  3  2  1  5  6 10  9  8  7
 5  4  3  2  1 10  9  8  7  6
 6 10  9  8  7  4  3  2  1  5
 7  6 10  9  8  3  2  1  5  4
 8  7  6 10  9  2  1  5  4  3
 9  8  7  6 10  1  5  4  3  2
10  9  8  7  6  5  4  3  2  1
},'group table ok');

done_testing();
