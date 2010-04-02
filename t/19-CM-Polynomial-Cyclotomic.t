use strict;
use warnings;
use Test::More;
use CM::Polynomial::Cyclotomic;
use Math::Factor::XS qw( factors);
use Math::Prime::XS  qw( is_prime);
use List::AllUtils qw/reduce all/;
use Math::Complex;  # The roots may be complex numbers.
use Math::Polynomial::Solve qw(poly_roots);
use feature ':5.10';
use Data::Dumper;


##############################################################################################
# just for testing purposes implementing Euler totient function(also known as Euler indicator)

sub phi {
	my ($n) = @_;

	return 1 if $n == 1;
	return $n-1 if is_prime($n);

	my @p = grep { is_prime($_) } ($n, factors($n));

	# last ,1 in the reduce param is for padding
	my $res =
	$n * (reduce { $a * ($b-1) } (1,@p))
	/
	(reduce { $a * $b } @p);

	return $res;

}


ok(phi(36)==12,'phi(36)=12');
ok(phi(15)==8,'phi(15)=8');



for(1..30) {
        ##########################################################################
        # checking if deg(\Theta_n) = phi(n)
        ##########################################################################
        my $n = $_;
	my $cyc = CM::Polynomial::Cyclotomic->new($_);
	ok($cyc->degree == phi($_), "degree of Theta_$_ = $cyc is ".phi($_));
        ##########################################################################
        # checking if roots of cyclotomic polynomial are also roots of unity
        # IOW  they verify   z^n = 1
        ##########################################################################

        my @roots = poly_roots($cyc->coefficients);
        #       print join("\n",@roots);

        ok(
            (
                all {
                    #apparently poly_roots returns Math::Complex objects when the roots
                    #are complex and scalars when they are real so we need to do this check

                    my @reim =  
                                    ref($_)
                                    ? @{ ($_**$n)->_cartesian }
                                    : ($_**$n,0);

                    abs($reim[0] - 1) < 0.0001 &&
                    abs($reim[1] - 0) < 0.0001; # zero for readability
                } @roots
            ),
            "all roots of Theta_$n are roots of unity"
        );
}






my $p = CM::Polynomial::Cyclotomic->new(5)*CM::Polynomial::Cyclotomic->new(7);
print "$p\n";










done_testing();
