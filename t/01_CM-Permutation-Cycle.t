use strict;
use warnings;
use lib './lib';
use Test::More 'no_plan';
use Test::Deep qw/cmp_deeply/;
use CM::Permutation::Cycle;
use Data::Dumper;
use List::AllUtils qw/all/;
#use feature 'say';
sub pc{#make new cycle
    CM::Permutation::Cycle->new(@_);
};

sub p{#make new permutation
    CM::Permutation->new(@_);
};

my $c1 = pc(4,5,1);

cmp_deeply(
    $c1->perm,
    [0,4,2,3,5,1],
    , 'cycle elements in place');

my $c2 = pc(3,2);

my $r11 = $c2*$c1;
ok($r11==p(4,3,2,5,1) , 'all elements in result of multiplication are as expected' );




ok(   p(3,1,2)*pc(3,2)==p(3,2,1) , 'cycle multiplied by permutation turned out fine' );
ok(  pc(2,3,1,4)==pc(4,2,3,1) , 'cycles are equal up to a circular permutation');
ok(  pc(2,3,1,4)==pc(1,4,2,3) , 'cycles are equal again');
ok(  pc(2,3,1,4)==pc(3,1,4,2) , 'cycles are equal yet again');
ok(!(pc(2,3,1,4)==pc(4,3,2,1)) , 'cycles are not equal now');


ok( pc(6,7)->order == 2 , 'order of (6,7) is 2');

ok( pc(2,3,1,4,5)->order == 5 , 'order of (2,3,1,4,5) is 5');


my $q = pc(2,3,1,4,5)*pc(6,7);

ok( $q->order == 10 , ' lcm(|(2,3,1,4,5)|,|6,7|)=10 ');

#print p(1,2,3,4,5)->order."\n";












