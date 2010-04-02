use strict;
use warnings;
use Test::More;
use CM::Polynomial::Chebyshev;
use Math::Polynomial;
use constant PI    => 4 * atan2(1, 1);


my $x = PI / 4;

for(1..20){
    
    
    #
    #if you do the change of variable X |----> cos(x) on T_n which is the nth Chebyshev polynomial
    #(x is constant while X is indeterminate)
    #then the evaluation of the polynomial at x is exactly cos(nx)
    #
    #IOW,   cos(nx) = T_n(cos(x))

    my $p =  CM::Polynomial::Chebyshev->new($_);
    my $v = $p->evaluate(cos($x));
    ok( abs(cos($_*$x) - $v) < 0.00000000001 , "trig identity for the T_$_ " );
    # even astronauts can use this(not sure if they'd use Perl for this but...)
}


done_testing();
