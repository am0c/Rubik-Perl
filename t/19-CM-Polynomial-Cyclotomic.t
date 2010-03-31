use strict;
use warnings;
use Test::More;
use CM::Polynomial::Cyclotomic;
use Math::Factor::XS qw( factors);
use Math::Prime::XS  qw( is_prime);
use List::AllUtils qw/reduce/;
use feature ':5.10';



################################################################
#
# just for testing purposes implementing euler totient function

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
	#print "$_";
	my $cyc = CM::Polynomial::Cyclotomic->new($_);
	ok($cyc->degree == phi($_), "degree of Theta_$_ = $cyc is ".phi($_));
}





