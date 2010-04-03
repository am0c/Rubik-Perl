package CM::Permutation::Cycle_Algorithm;
use Moose;
use List::AllUtils qw/first/;
use CM::Permutation::Cycle;
extends 'CM::Permutation';

use overload '""' => 'str_decomposed'; # "" and == are used by uniq from List::AllUtils in the tests
=pod

=head1 NAME

CM::Permutation::Cycle_Algorithm - An algorithm for finding the disjoint cycle decomposition of a permutation.

=head2 uncover_cycle()

Given an element will apply the permutation to that element , then to the image of that element
and so forth, yielding  x,p(x),p(p(x)),... and after a finite number of iterations the number will return
to x, this defines the cycle.

=head2 str_decomposed()

Writes the permutation as a product of cycles and returns a string with this data.

=head2 run()

Returns an array containing all cycles of the permutation.

=head2 get_first_unmarked()

Gets the first unmarked element of the permutation(it's marked only if it's already found to be part of a cycle).

=head1 SEE ALSO

Abstract Algebra                            -   David S. Dummit , Richard M. Foote , page 30

Combinatorial Topics Techniques Algorithms  -   Peter J. Cameron page 30

=head1 AUTHOR

Stefan Petrea, C<< <stefan.petrea at gmail.com> >>

=cut







has marked => (
    isa => 'ArrayRef[Bool]',
    is  => 'rw',
    default => sub {[]},
);

has cycles   => (
    isa => 'ArrayRef[ArrayRef[CM::Permutation::Cycle]]',
    is  => 'rw',
    default => sub {[]},
);

sub get_first_unmarked {
    my ($self)=@_;
    return first {
        !$self->marked->[$_]
    } 1..-1+@{$self->perm};
}

sub uncover_cycle {
    my ($self,$start) = @_;
    warn "already uncovered" if $self->marked->[$start];
    my $current = $start;
    my $new_cycle = [];
    while(1) {
        $current = $self->perm->[$current];
        $self->marked->[$current] = 1;
        push @$new_cycle,$current;
        last if $current == $start;
    };
    push @{$self->cycles},CM::Permutation::Cycle->new(@$new_cycle);
}

sub run {
    my ($self,$start) = @_;
    while(my $unmarked = $self->get_first_unmarked) {
        $self->uncover_cycle($unmarked);
    };
    return @{$self->cycles};
}

sub str_decomposed {
    my ($self) = @_;
    my $rep =
    join
    ('*',
        (
            map {"$_"} @{$self->cycles}
        )
    );
    $rep;
}


1;
