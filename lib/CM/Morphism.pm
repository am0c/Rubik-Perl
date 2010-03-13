package CM::Morphism;
use strict;
use warnings;
use Moose;


# this will be a group homomorphism which we'll prove 
# step by step to be an epimorphism or a monomorphism
has f => (
	isa      => 'CodeRef',
	is       => 'rw',
	required => 1,
);


# can I write regexes instead of isas ? 

has domain => (
	isa      => 'CM::Group',
	is       => 'rw',
	required => 1,
);



has codomain => (
	isa      => 'CM::Group',
	is       => 'rw',
	required => 1,
);


# prove that this is indeed a morphism
sub prove {
	my ($self) = @_;
	my $f = $self->f;
	all {
		my $x = $_;
		all {
			my $y = $_;

			# * means the group operations here not multiplication..
			$f->( $x   *       $y ) ==
			$f->( $x ) * $f->( $y );

		} @{$self->codomain->elements}
	} @{$self->domain->elements};
}


# however , the kernel and the image are groups themselves so we should create a subgroup of domain
# and one of codomain and equip them with the elements and return them

sub kernel {
	my ($self) = @_;
	grep {
		$self->f->($_) == 
		$self->codomain->identity;
	} @{$self->domain->elements};
}

sub image {
	my ($self) = @_;
	map {
		$self->f->($_);
	} @{$self->domain->elements};
}

1;
