package CM::Tuple;
use Moose;
use strict;
use warnings;
use overload
"*"  => \&multiply,
"==" => \&equal;


has label => (
	isa=> 'Int',
	is => 'rw',
	default => undef,
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

sub equal {
	my ($op1,$op2) = @_;
	return
	$op1->first  == $op2->first &&
	$op2->second == $op2->second;
};


1;
