package CM::Polynomial::Cyclotomic;
use strict;
use warnings;
use Moose;
use Math::Polynomial;
use Math::Factor::XS qw( factors);
use Math::Prime::XS  qw( is_prime);
use Math::BigInt;
use List::AllUtils qw/reduce first/;
use File::Slurp qw/slurp/;
use Cwd;
use Path::Class qw/file/;
extends 'Math::Polynomial';





my @mu;

# the file contains the precomputed Möbius function mu(x) up to 10^5 we won't need more
# table located right here ---> http://www.research.att.com/njas/sequences/A008683


# just make getting the data file portable
my $dir = Path::Class::File->new(__FILE__)->dir;
my $mobdata = file($dir,'Möbius.data');

#print $mobdata;

@mu = split(/,/,"$mobdata");

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
	# CASE I   n is a prime
	# \Theta_n = 1 + X + X^2 + ... + X^(p-1)     for p a prime
	return Math::Polynomial->new( (1) x $n ) 
	if is_prime($n);



	###############################################################
	# CASE II  n is a power of a prime
	#
	# there is a relation of the \Theta_p^m(X) = \Theta_p(X^p)
	# through the Frobenius morphism  X |----------> X^p
	# this can be proved and gives an easy way of computing the p^m th cyclotomic polynomial

	my @factors = factors($n);

	my $first_pdiv = first { is_prime($_) } @factors; # first prime divisor of $n
	# an unfortunate function name..
	my $log = Math::BigInt::blog($n,$first_pdiv);

	#this can also be done with (1,(p-1) zeros , 1 , (p-1) zeros, 1, <--- this should happen about m times)
	#
	return Math::Polynomial->new( (1) x $log )->nest(
		Math::Polynomial->new( 
			(0) x ($first_pdiv) , 1
		)
	)
	if $log == int($log); # if $n is the power of a prime


	
	###############################################################
	# CASE III using Möbius inversion
	#
	# in the general case the cyclotomic polynomial can be computed using Mobius inversion

	my $r = Math::Polynomial->new(1);

	for my $d ( @factors ) {
		next if $d == $n;

		$r *= gen_pol($d);
	};

	return 

	Math::Polynomial->new(-1,(0) x ($n - 1) , 1)
	/
	$r;
}


1;
