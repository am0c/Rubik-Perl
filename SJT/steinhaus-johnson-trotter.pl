use strict;
use warnings;
use Test::More ;

#
# Wed 24 Feb 2010 11:00:17 AM EST
# reimplementing this using Inline::C would  be a very good idea
# (that way I could learn some SV_* stuff and also make my stuff faster)
# I think just the first permutation has to be ($n..1) in order for tests not to start
# failing for CM::P and all related modules

# turns out I can't use this.. because the order of the permutations generated is different..

# on wikipedia there's an article about this algorithm
# http://en.wikipedia.org/wiki/Steinhaus%E2%80%93Johnson%E2%80%93Trotter_algorithm

my $LEFT = -1;
my $RIGHT= 1;

my $n = 4;


# the first one is the number , second is direction
my @p = ( 0 , map { [$_,$LEFT]  }  (1..$n) ) ; # permutation vector ( 
                                               #                     we store the actual number in the first one
                                               #                     and position in the second
                                               #                     )


sub mobile {
    # positions from 1..@p-1
    # returns if a position contains a number that is mobile or not
    my ($pos) = @_;
    return 0 if $pos + $p[$pos]->[1] > $n ||
                $pos + $p[$pos]->[1] ==0;

    $p[$pos + $p[$pos]->[1]]->[0] <
    $p[$pos]->[0];
}

sub emobile {
    #returns the position of the largest mobile integer if any
    #and 0 otherwise

    my $maxpos = 0;
    my $max = 0;
    for(my $i=1;$i<=$n;$i++) {

        next unless mobile($i);

        if($p[$i]->[0] > $max) {
            ($maxpos,$max) = ($i,$p[$i]->[0]);

            if($max==$n) {
                return $maxpos;
            };
        };
    };
    return $maxpos;
}

sub xchg {
    my ($i,$j) = @_;
    my $temp = $p[$i];
    $p[$i] = $p[$j];
    $p[$j] = $temp;
}

sub print_perm {
    map {
        print $p[$_]->[1] == 1
              ? '>'
              : '<';
        print $p[$_]->[0];
        print " ";
    } (1..$n);
    print "\n";
}


ok(emobile()==$n,'first mobile element is on position 3');



print_perm;

while(my $k = emobile()) {
    # k is only a position and not the actual number (which is $p[$k]->[0]

    print "exchanged positions $k,".($k+$p[$k]->[1])."\n";

    my $max_mob = $p[$k]->[0]; # maximum mobile; we store this because after the
                               # xchg positions will change..so only the value will
                               # matter

    xchg(
        $k,
        $k+$p[$k]->[1]
        );
    

    map {
        if( $p[$_]->[0] > $max_mob ) {
            print "reversed direction for position $_\n";
            $p[$_]->[1] *= -1;
        };
    } (1..$n);
    
    print_perm;
    <>;
}



