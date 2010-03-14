package CM::EquivalenceClass;
use Moose;
use Set::Scalar;

use overload '==' => 'equal';



# implementation problems
# -----------------------
#
# how do I choose representant for a class ?
#
# how is multiplication of equivalence classes carried out if I don't know what the elements of the
# equivalence class of the results are(at most I'll know the representant)
#
# when I pass representant an element other than a representant then it should identify what the real
# representat should have been ?

has representant => (
	isa      => 'Any',
	is       => 'rw',
	required => 1,
);

has label => (
	isa      => 'Int',
	is       => 'rw',
	required => 1,
);


has elements => (
	isa      => 'ArrayRef',
	is       => 'rw',
	required => 1 ,
);


sub equal {
	my ($x,$y) = @_;
	# two equivalence classes are equal if they have at least one element in common
	# (or .. their representants are equal)
	
	return 1 if $x->representant == $y->representant;
	
	return (
			Set::Scalar->new(@{$x->elements}) * 
			Set::Scalar->new(@{$y->elements})
			)->size;
}



