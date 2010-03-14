package CM::Morphism;
use strict;
use warnings;
use Moose;
use Moose::Util::TypeConstraints;


type 'Group'
	=> where {
		#print "$_\n" for @{$_::ISA};
		$_->does('CM::Group'); # $_ does the role CM::Group
		#$_->isa('CM::Group::Sym');
		#/^CM::Group/ && print "YAYYYY";
	};



# this will be a group homomorphism which we'll prove 
# step by step to be an epimorphism or a monomorphism
has f => (
	isa      => 'CodeRef',
	is       => 'rw',
	required => 1,
);


# can I write regexes instead of isas ? 

has domain => (
	isa      => 'Group',
	is       => 'rw',
	required => 1,
);



has codomain => (
	isa      => 'Group',
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


# the kernel and the image are groups themselves so we should create a subgroup of domain and codomain
sub kernel {
	my ($self) = @_;
	
	my $group = $self->domain->meta->name->new({n=>1});
	$group->compute_elements(sub{});

	my @elements = 
	grep {
		$self->f->($_) == 
		$self->codomain->identity;
	} @{$self->domain->elements};

	$group->elements(\@elements);


	return $group;
}

sub image {
	my ($self) = @_;

	my $group = $self->codomain->meta->name->new({n=>1});
	$group->compute_elements(sub{});

	my @elements = 
	map {
		$self->f->($_);
	} @{$self->domain->elements};


	$group->elements(\@elements);

	return $group;
}

1;
