package CM::Group::ModuloAddition;
use Moose;
extends 'CM::Group::ModuloMultiplication';


=head1 DESCRIPTION

The group (Z_n,+)

=cut

sub operation {
    my ($self,$a,$b) = @_;

    my $result = ($a->object + $b->object) % $self->n;
    my $element = CM::ModuleInt->new( $result );
    $element->label( $a->object * $b->object );

    return $element;
}


1;
