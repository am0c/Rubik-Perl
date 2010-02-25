use strict;
use warnings;
use Test::More;
use List::AllUtils qw/all max/;
use CM::Rubik;
use Carp;
use Data::Dumper;


# need to write tests and wrap around eval for all generators of Rubik's cube
# and see if any of them fails to return a valid permutation


my $m = CM::Rubik->new();

#print "\n"x10;
#print $m->comb("FRFRFR")."\n";
#exit;


my $p = $m->rotate_face(1..9);

ok( (all { defined($_) }(@{$p->perm})), "all elements of permutation are defined");



# need to test all moves , for example $m->B doesn't work at this time.

my $F = $m->F;
my $R = $m->R;
my $L = $m->L;
my $B = $m->B;
my $U = $m->U;
my $D = $m->D;


my $moves = {
    F => $F,
    R => $R,
    L => $L,
    D => $D,
    U => $U,
    B => $B,
};



sub legend {
    print "LEGEND\n";
    for my $i(qw/F R L B U D/) {
        my $ni = '$'.$i;
        print "$i: ".$moves->{$i}."\n";
    }
}



ok(($F*$U*$R*$B*$L)->order()    == 252,'order of FURBL is 252');

ok(($F*$B*$D*$U*$L*$R)->order() == 4, 'order of FBDULR is 4');

my @states = ($F,$R);#,$L,$B,$U,$D);

#my $m->config = $m->config * $m->F;

my $i = 0;
my $q = $F;

#print $q."\n";


done_testing(); exit 0;

while(1) {
    my $w  = ~~@{$q->perm} - 1;
    my $m  = max(@{$q->perm});
    confess "detected duplicates w=$w m=$m" if  $w != $m;
    $q = $q * $states[++$i % @states];
    #legend();
    #print"q=\n$q\n";
    <>;
}


done_testing;
