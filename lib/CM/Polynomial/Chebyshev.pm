package CM::Polynomial::Chebyshev;
use strict;
use warnings;
use Moose;
extends 'Math::Polynomial';
use Data::Dumper;

 
sub new {
	my ($self,$n) = @_;

	$self->SUPER::new(@{ cheb($n)->[0] });

};



sub cheb {
	my ($n) = @_;

	#print "cheb $n\n";
	return Math::Polynomial->new(1)
	if $n == 0;

	return Math::Polynomial->new(0,1)
	if $n == 1;

	return Math::Polynomial->new(0,2) * cheb($n-1) - cheb($n-2);
}

1;
