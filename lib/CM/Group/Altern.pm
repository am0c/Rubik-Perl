package CM::Group::Altern;
use Moose;
extends 'CM::Group::Sym';

=head1 NAME

CM::Group::Altern - The alternating group of degree n.

=head1 DESCRIPTION

CM::Group::Altern is an implementation of the Alternating Group A_n which is a subgroup of the symmetric group S_n

CM::Group::Altern is derived from CM::Group::Sym

=head1 SYNOPSIS

    use CM::Group::Altern;
    my $G1 = CM::Group::Altern->new({$n=>4});
    $G1->compute();
    print $G1

    12 11 10  9  8  7  6  5  4  3  2  1
    11 10 12  8  6  4  9  7  5  1  3  2
    10 12 11  6  9  5  8  4  7  2  1  3
     9  5  1  3  7  2 11  6 10 12  8  4
     8  7  2  1  4  3 10  9 12 11  6  5
     7  2  8  4 10 12  1  3  9  5 11  6
     6  4  3  2  5  1 12  8 11 10  9  7
     5  1  9  7 11 10  3  2  6  4 12  8
     4  3  6  5 12 11  2  1  8  7 10  9
     3  6  4 12  2  8  5 11  1  9  7 10
     2  8  7 10  1  9  4 12  3  6  5 11
     1  9  5 11  3  6  7 10  2  8  4 12

=head1 SEE ALSO

L<CM::Group::Sym> 

L<http://en.wikipedia.org/wiki/Alternating_group>

=head1 AUTHOR

Stefan Petrea, C<< <stefan.petrea at gmail.com> >>

=cut

sub _builder_order {
    my ($self) = @_;
    $self->SUPER::_builder_order() / 2;
    # alternative group has half as many permutations as the symmetric group which
    # the alternating group is a subgroup of
}




# TODO: must fix this with method modifiers - overrides method from Sym.pm
sub _compute_elements {
    my ($self) = @_;
	sub {
		my $label = 0;
		my @permutations;
		my $p = new Algorithm::Permute([1..$self->n]);
		while (my @new_perm = $p->next) {
			my $new_one = CM::Permutation->new(@new_perm);
			next unless $new_one->even_odd == 0; # only even permutations
			$self->add_to_elements($new_one);
		};
	}
}


1;
