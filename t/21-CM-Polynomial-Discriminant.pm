use CM::Polynomial::Discriminant;
package Disc;
use Moose;
extends 'Math::Polynomial';
with 'CM::Polynomial::Discriminant';



package main;
use Test::More qw/no_plan/;




#according to Pari/GP and  http://www.wolframalpha.com/input/?i=discriminant+of+4%2B5x%2Bx^2+%2B+8x^3
#disc(4+5x+x^2+8x^3) = -28759

sub dtest {
    my $val = shift;
    my $m = Disc->new(@{ $_[0] });
    #print join("\n",$m->shifts);
    my $got = sprintf("%s",$m->discriminant);
    ok($got==$val,"discriminant of ".$m." is ".$m->discriminant.", expected $val");
}

dtest(-28759,[4,5,1,8]);
dtest(-47775744,[4,0,0,0,0,0,1]);
dtest(5292000,[10,0,15,0,3]);

