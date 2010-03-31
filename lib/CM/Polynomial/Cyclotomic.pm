package CM::Polynomial::Cyclotomic;
use strict;
use warnings;
use Moose;
use Math::Polynomial;
use Math::Factor::XS qw( factors);
use Math::Prime::XS  qw( is_prime);
use Math::BigFloat;
use List::AllUtils qw/reduce first part/;
use File::Slurp qw/slurp/;
use Cwd;
use Path::Class qw/file/;
use Data::Dumper;
extends 'Math::Polynomial';





my @mu;

# the file contains the precomputed Möbius function mu(x) up to 10^5 (should be enough)
# table located right here ---> http://www.research.att.com/njas/sequences/A008683


# just make getting the data file portable
my $dir = Path::Class::File->new(__FILE__)->dir;
my $mobdata = file($dir,'Möbius.data');

#print $mobdata;

@mu = split(/,/,slurp("$mobdata"));

# cache by n, \Theta_n is the nth cyclotomic polynomial
# the first cyclotomic polynomial is X-1



my @cache = (Math::Polynomial->new(-1,+1)); 


sub new {
	my ($self,$n) = @_;

	$self->SUPER::new(@{ gen_pol($n)->[0] });
}





sub gen_pol {
	my ($n) = @_;


	###############################################################
	# CASE I n is 1
	
	return Math::Polynomial->new(-1,1)
	if $n == 1;



	###############################################################
	# CASE II   n is a prime
	# \Theta_n = 1 + X + X^2 + ... + X^(p-1)     for p a prime
	return Math::Polynomial->new( (1) x $n ) 
	if is_prime($n);



	###############################################################
	# CASE III  n is a power of a prime
	#
	# there is a relation of the \Theta_p^m(X) = \Theta_p(X^p)
	# through the Frobenius morphism  X |----------> X^p
	# this can be proved and gives an easy way of computing the p^m th cyclotomic polynomial


	my @factors = factors($n);

	my $p = first { is_prime($_) } @factors; # first prime divisor of $n
	# an unfortunate function name..
	my $log = Math::BigFloat->new($n)->blog($p);


	#print "$log";

	#this can also be done with (1,(p-1) zeros , 1 , (p-1) zeros, 1, <--- this should happen about m times)
	#
	return Math::Polynomial->new( (1) x $p )->nest(
		Math::Polynomial->new( 
			(0) x ($p**($log-1)) , 1
		)
	)
	if $log == int($log); # if $n is the power of a prime

	#print "after\n";

	
	###############################################################
	# CASE IV general case
	#
	# in the general case the cyclotomic polynomial can be computed using Mobius inversion

   my $r = Math::Polynomial->new(1);

	for my $d ( 1, @factors ) {
		next if $d == $n;
		#print "d=$d\n";

		$r *= gen_pol($d);
	};

	return 

	Math::Polynomial->new(-1,(0) x ($n - 1) , 1)

	/

	$r;




# using Möbius inversion (not yet tested) for the general case

#ignore the factors with mu 0 , because the result polynomials will be 1 in the formula
#then partition the values left into 2 buckets which will become the numerator and denominator
#respectively , then multiply all in each bucket separately and now we have just 2 polynomials which are
#denom and numerat of a fraction , divide and that's all


# NOTE: doesn't work for n > 9

#	reduce { $a / $b }
#	map {
#
#		reduce { $a * $b } 
#		map {
#			Math::Polynomial->new(1,(0) x ($_-1),1)
#		} @$_;
#	}
#	part {
#		1 + $mu[$_]
#	} 
#	grep {
#		$mu[$_] != 0;
#	}
#	@factors;

}


1;
