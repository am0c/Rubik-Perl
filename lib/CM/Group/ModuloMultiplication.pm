# this will be a bit like mocking a class since most of the API needs to be faked to make the
# machinery we wrote so far work
#
package CM::ModuleInt;
use Moose;
#use MooseX::Aliases;
use overload    "*" => \&multiply,
                '""'=> \&stringify,
                '+'=> \&addition,
                '=='=> \&equal;


# TODO: add ModuloAddition.pm

=head1 NAME

CM::Group::ModuloMultiplicationGroup

=head1 DESCRIPTION

The group (Z_n,*)

=cut


has object =>(
    isa => 'Int',
    is  => 'rw',
    required => 1,
);

has label => (
    isa => 'Int',
    is  => 'rw',
    default => -1,
);

sub stringify {
    my ($self) = @_;
    return $self->object;
}

sub multiply {
    my ($right,$left) = @_;
    return CM::ModuleInt->new($right->object * $left->object);
}

sub addition {
    my ($right,$left) = @_;
    return CM::ModuleInt->new($right->object + $left->object);
}


sub equal {
    my ($right,$left) = @_;
    return $right->object == $left->object;
}

sub BUILDARGS {
    my ($self,$arg) = @_;
    {
        object    => $arg,
    };
}


package CM::Group::ModuloMultiplication;
# Modulo Multiplication Group
# http://mathworld.wolfram.com/ModuloMultiplicationGroup.html
use Moose;
use overload '""' => 'stringify'; # I think there was a bug on rt.cpan.org saying that overload does not work well
use List::AllUtils qw/first/;

with 'CM::Group' => { element_type => 'CM::ModuleInt'  };


# NOTE: when override doesn't work use around

sub operation {
    my ($self,$a,$b) = @_;

    my $result = ($a->object * $b->object) % $self->n;
    my $element = CM::ModuleInt->new( $result );
    $element->label( $a->object * $b->object );

    return $element;
}

sub _compute_elements {
    my ($self) = @_;
	sub {
		$self->tlabel(0); # start labels from 0

		for (0..-1+$self->n) {
			print "adding element $_\n";
			$self->add_to_elements(CM::ModuleInt->new($_));
		};
	}
}

sub _builder_order {
    my ($self) = @_;
    return $self->n;
}

sub identity {
    my ($self) = @_;
    return first { $_->object == 1 } @{$self->elements} ; # for some reason it's not in elements->[1]
}
=head1 AUTHOR

Stefan Petrea, C<< <stefan.petrea at gmail.com> >>

=cut



1;
