package CM::Tuple;
use Moose;
use strict;
use warnings;
use Math::BigInt qw/blcm/;
use List::AllUtils qw/reduce/;
use overload
"*"  => 'multiply',
'==' => 'equal',
'**' => 'power',
'""' => 'stringify'; 


=head1 DESCRIPTION

CM::Tuple is used to describe a tuple of 2 elements.
The composition operation is on components.
This is written in order to facilitate the construction of direct products of groups whose elements are these tuples.

=cut


#
# Problem : the operation wrapper from CM::Group should apply to the * of each of the elements when inside the
# overloaded "*" operator , but it doesn't because CM::Tuple is not dependent on anything from CM::Group.
# This will be a problem for ModuloMultiplication for example which relies on this..
#



has label => (
	isa=> 'Int',
	is => 'rw',
	default => 1,
);

has tlabel => (
	isa=> 'Int',
	is => 'rw',
	default => 1,
);


# maybe these 2 should be ro
has first => (
	isa	=> 'Any',
	is => 'rw',
	default => undef,
	required => 1,
);

has second => (
	isa	=> 'Any',
	is => 'rw',
	default => undef,
	required => 1,
);

sub multiply {
	my ($op1,$op2)=@_;

	return $op1->new(
		{
			first => $op1->first  * $op2->first  ,
			second=> $op1->second * $op2->second ,
		}
	);
};

sub power {
	my ($self,$n) = @_;
	reduce { $a * $b }  ( ($self) x ($n) );
}

sub equal {
	my ($op1,$op2) = @_;
	return
	$op1->first  == $op2->first &&
	$op2->second == $op2->second;
};

sub stringify {
	my ($self) = @_;
	return sprintf("[%s|%s]",$self->first,$self->second);
}

sub order {
	my ($self) = @_;
	return blcm($self->first->order,$self->second->order);
}


1;
