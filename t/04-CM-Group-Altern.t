use strict;
use warnings;
use lib './lib/';
use Test::More;
use CM::Group::Altern;

my $g = CM::Group::Altern->new({n=>4});
$g->compute();

print $g;
ok($g->order==12,'A_4 order is good');
ok("$g" eq '12 11 10  9  8  7  6  5  4  3  2  1
11 10 12  8  6  4  9  7  5  1  3  2
10 12 11  6  9  5  8  4  7  2  1  3
 9  5  1  3  7  2 11  6 10 12  8  4
 8  7  2  1  4  3 10  9 12 11  6  5
 7  2  8  4 10 12  1  3  9  5 11  6
 6  4  3  2  5  1 12  8 11 10  9  7
 5  1  9  7 11 10  3  2  6  4 12  8
 4  3  6  5 12 11  2  1  8  7 10  9
 3  6  4 12  2  8  5 11  1  9  7 10
 2  8  7 10  1  9  4 12  3  6  5 11
 1  9  5 11  3  6  7 10  2  8  4 12
','A_4 table good');

done_testing();
