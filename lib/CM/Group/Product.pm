package CM::Group::Product;
use Moose;
use CM::Tuple;
use strict;
use warnings;
with 'CM::Group' => { element_type => 'CM::Tuple'  };


#   #http://en.wikipedia.org/wiki/Direct_product
has groupG => (
	isa => 'CM::Group',
	is => 'rw',
	required => 1,
);

has groupH => (
	isa => 'CM::Group',
	is => 'rw',
	required => 1,
);


sub operation {
    my ($self,$a,$b) = @_;
    my $first  = $self->groupG->operation($a->first ,$b->first);
    my $second = $self->groupH->operation($a->second,$b->second);
    return CM::Tuple->new({
		    first => $first,
		    second=> $second,
    });
}


# because the direct product of groups has as many elements as the product of the groups
sub _builder_order {
    my ($self) = @_;
    return $self->groupG->_builder_order * $self->groupH->_builder_order;
}


sub _compute_elements {
	my ($self) = @_;
	sub {
		my @elements;

		$self->groupG->compute_elements->() unless @{$self->groupG->elements};
		$self->groupH->compute_elements->() unless @{$self->groupH->elements};

		for my $g (@{$self->groupG->elements}) {
			for my $h (@{$self->groupH->elements}) {
				$self->add_to_elements(
					CM::Tuple->new({
							first =>$g,
							second=>$h,
						})
				);
			};
		};
	}
};

sub identity {
	my ($self) = @_;

	return CM::Tuple->new({
			first => $self->groupG->identity,
			second=> $self->groupH->identity,
		});
};



1;
