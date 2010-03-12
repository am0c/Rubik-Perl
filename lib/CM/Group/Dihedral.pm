package CM::Group::Dihedral;
use Moose;
use CM::Permutation;
use Carp;
use overload '""' => 'stringify'; # I think there was a bug on rt.cpan.org saying that overload does not work well
                                  # with parametrized roles so I cannot abstract this ..yet but I'm not sure..have to
                                  # check
use List::AllUtils qw/all first/;
# the elments of a Dihedral group are rotational and reflectional symmetries of a polygon
with 'CM::Group' => { element_type => 'CM::Permutation'  };



=pod

=head1 NAME

CM::Group::Dihedral - An implementation of the finite dihedral group D_2n

=head1 DESCRIPTION

This group is formed of the reflectional and rotational symmetries of a regular polygon with n edges.
It is also the symmetry group of a regular polygon.

=head1 SYNOPSIS

	use CM::Group::Dihedral;
	my $g = CM::Group::Dihedral->new({n=>10});
	$g->compute;
	print "$g";

	1 10  9  8  7  6  5  4  3  2  19 18 17 16 15 14 13 12 11 20
	2  1 10  9  8  7  6  5  4  3  18 17 16 15 14 13 12 11 20 19
	3  2  1 10  9  8  7  6  5  4  17 16 15 14 13 12 11 20 19 18
	4  3  2  1 10  9  8  7  6  5  16 15 14 13 12 11 20 19 18 17
	5  4  3  2  1 10  9  8  7  6  15 14 13 12 11 20 19 18 17 16
	6  5  4  3  2  1 10  9  8  7  14 13 12 11 20 19 18 17 16 15
	7  6  5  4  3  2  1 10  9  8  13 12 11 20 19 18 17 16 15 14
	8  7  6  5  4  3  2  1 10  9  12 11 20 19 18 17 16 15 14 13
	9  8  7  6  5  4  3  2  1 10  11 20 19 18 17 16 15 14 13 12
	10  9  8  7  6  5  4  3  2  1 20 19 18 17 16 15 14 13 12 11
	11 20 19 18 17 16 15 14 13 12  9  8  7  6  5  4  3  2  1 10
	12 11 20 19 18 17 16 15 14 13  8  7  6  5  4  3  2  1 10  9
	13 12 11 20 19 18 17 16 15 14  7  6  5  4  3  2  1 10  9  8
	14 13 12 11 20 19 18 17 16 15  6  5  4  3  2  1 10  9  8  7
	15 14 13 12 11 20 19 18 17 16  5  4  3  2  1 10  9  8  7  6
	16 15 14 13 12 11 20 19 18 17  4  3  2  1 10  9  8  7  6  5
	17 16 15 14 13 12 11 20 19 18  3  2  1 10  9  8  7  6  5  4
	18 17 16 15 14 13 12 11 20 19  2  1 10  9  8  7  6  5  4  3
	19 18 17 16 15 14 13 12 11 20  1 10  9  8  7  6  5  4  3  2
	20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1


	$g->rearrange; # we rearrange so that identity sits on the first diagonal
	print "$g";


	 1 10  9  8  7  6  5  4  3  2 19 18 17 16 15 14 13 12 11 20
	 2  1 10  9  8  7  6  5  4  3 18 17 16 15 14 13 12 11 20 19
	 3  2  1 10  9  8  7  6  5  4 17 16 15 14 13 12 11 20 19 18
	 4  3  2  1 10  9  8  7  6  5 16 15 14 13 12 11 20 19 18 17
	 5  4  3  2  1 10  9  8  7  6 15 14 13 12 11 20 19 18 17 16
	 6  5  4  3  2  1 10  9  8  7 14 13 12 11 20 19 18 17 16 15
	 7  6  5  4  3  2  1 10  9  8 13 12 11 20 19 18 17 16 15 14
	 8  7  6  5  4  3  2  1 10  9 12 11 20 19 18 17 16 15 14 13
	 9  8  7  6  5  4  3  2  1 10 11 20 19 18 17 16 15 14 13 12
	10  9  8  7  6  5  4  3  2  1 20 19 18 17 16 15 14 13 12 11
	19 18 17 16 15 14 13 12 11 20  1 10  9  8  7  6  5  4  3  2
	18 17 16 15 14 13 12 11 20 19  2  1 10  9  8  7  6  5  4  3
	17 16 15 14 13 12 11 20 19 18  3  2  1 10  9  8  7  6  5  4
	16 15 14 13 12 11 20 19 18 17  4  3  2  1 10  9  8  7  6  5
	15 14 13 12 11 20 19 18 17 16  5  4  3  2  1 10  9  8  7  6
	14 13 12 11 20 19 18 17 16 15  6  5  4  3  2  1 10  9  8  7
	13 12 11 20 19 18 17 16 15 14  7  6  5  4  3  2  1 10  9  8
	12 11 20 19 18 17 16 15 14 13  8  7  6  5  4  3  2  1 10  9
	11 20 19 18 17 16 15 14 13 12  9  8  7  6  5  4  3  2  1 10
	20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1


These are labels of the elements and not the elements themselves(which internally are represented as permutations).

You can also see a coloured Cayley table(the labels of the permutations are associated to colours):


=begin html

<p><center><img src="http://perlhobby.googlecode.com/svn/trunk/scripturi_perl_teste/cm-permutation/cpan/CM-Permutation/Dihedral_colour.PNG" /></center></p>

=end html




This is the Cayley graph of D_5:


=begin html

<p><center><img src="http://perlhobby.googlecode.com/svn/trunk/scripturi_perl_teste/cm-permutation/cpan/CM-Permutation/dihedral.gif" /></center></p>

=end html


=cut



# Rgen and Sgen are the canonical generators of this group

sub Rgen {
    my ($self) = @_;
    # rotates  vertices of a polygon by  2pi/$n
    return CM::Permutation::Cycle->new(1..$self->n);
}

sub Sgen {
    my ($self) = @_;
    return CM::Permutation->new(reverse(1..$self->n));     
    # reflects vertices of a polygon with repsect to to the line passing 
    # through the first point of the polygon
}

sub _compute_elements {
    my ($self) = @_;
	sub {
		my $n    = $self->n;
		my $half = $n / 2;
		$self->tlabel(1);# reset initial label for elements

		my @rotated;

		my $I = CM::Permutation->new(1..$n);

		my ($R,$S) = ($self->Rgen,$self->Sgen);


		for(1..$n) {
			$self->add_to_elements($I);
			push @rotated,$I;
			$I = $I * $R;
		};

		my @reflected = 
		map { $self->add_to_elements($S * $_) } @rotated;
	}
}


sub _builder_order {
    my ($self) = @_;
    return $self->n << 1; # * 2
}


# TODO:  - put compute , identity and strigify in Group.pm
#        - define a class GroupElement which will have attributes:
#               - label
#               - object(the actual object)
#               - stringify
#
#   (there are various parts of the tests and code that need to be
#    checked to see that all will fit well after abstracting to GroupElement)





sub identity {
    my ($self) = @_;
    my $e = CM::Permutation->new(1..$self->n);
    first {
        $_ == $e;
    } @{ $self->elements };
}

# TODO: use http://search.cpan.org/~bobtfish/MooseX-Role-WithOverloading-0.05/lib/MooseX/Role/WithOverloading.pm
# for providing overloaded operators from within the role Group and remove stringify from here

sub stringify {
    my ($self) = @_;
    my $table = Text::Table->new;
    my $order = $self->order; #reduce { $a * $b  } 1..$self->n;
    my @for_table;
    for my $i (0..-1+$order) {
        my @new_line = map{ $_->label  } @{$self->operation_table->[$i]};
        push @for_table,\@new_line;
    }
    $table->load( @for_table );
    return "$table";
}

sub operation {
    my ($self,$a,$b) = @_;
    return $a*$b;
}

=head1 AUTHOR

Stefan Petrea, C<< <stefan.petrea at gmail.com> >>

=cut


1;
