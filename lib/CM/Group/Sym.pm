package CM::Group::Sym;
use Moose;
use CM::Permutation;
use CM::Permutation::Cycle_Algorithm;
use Algorithm::Permute;
#use feature 'say';
use List::AllUtils qw/zip all sum uniq reduce first first_index/;
use overload '""' => 'stringify';
use Math::BigInt;
use Bit::Vector;
use Carp;
use Params::Validate qw/:all/;
with 'CM::Group' => { element_type => 'CM::Permutation'  };

#
# making the tuple type and using it as a parameter for this role will require reading
#
# perldoc -f blessed
# preldoc -f ref
#
# http://search.cpan.org/~flora/MooseX-Types-Structured-0.20/lib/MooseX/Types/Structured.pm
# http://search.cpan.org/~drolsky/Moose-0.98/lib/Moose/Meta/Role.pm
# http://search.cpan.org/~drolsky/Moose-0.98/lib/Moose/Meta/Class.pm
# http://search.cpan.org/~drolsky/Class-MOP-0.98/lib/Class/MOP/Class.pm
#







=pod

=head1 NAME

CM::Group::Sym - An implementation of the finite symmetric group S_n

=head1 DESCRIPTION

CM::Group::Sym is an implementation of the finite Symmetric Group S_n

=head1 SYNOPSIS

    use CM::Group::Sym;
    my $G1 = CM::Group::Sym->new({n=>3});
    my $G2 = CM::Group::Sym->new({n=>4});
    $G1->compute();
    $G2->compute();

This way you will generate S_3 with all it's 6 elements which are permutations.
Say you want to print the operation table(Cayley table).
    
    print $G1

    6 5 4 3 2 1
    3 4 5 6 1 2
    2 1 6 5 4 3
    5 6 1 2 3 4
    4 3 2 1 6 5
    1 2 3 4 5 6

or the table of S_4 with 24 elements

    print $G2

    24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1
    23 24 20 16 22 18 19 15 21 17 13 14 11 12  8  4 10  6  7  3  9  5  1  2
    22 18 19 15 23 24 20 16 11 12  8  4 21 17 13 14  9  5  1  2 10  6  7  3
    21 17 13 14  9  5  1  2 10  6  7  3 22 18 19 15 23 24 20 16 11 12  8  4
    20 19 18 17 24 23 22 21 12 11 10  9 16 15 14 13  4  3  2  1  8  7  6  5
    19 20 24 12 18 22 23 11 17 21  9 10 15 16  4  8 14  2  3  7 13  1  5  6
    18 22 23 11 19 20 24 12 15 16  4  8 17 21  9 10 13  1  5  6 14  2  3  7
    17 21  9 10 13  1  5  6 14  2  3  7 18 22 23 11 19 20 24 12 15 16  4  8
    16 15 14 13  4  3  2  1  8  7  6  5 20 19 18 17 24 23 22 21 12 11 10  9
    15 16  4  8 14  2  3  7 13  1  5  6 19 20 24 12 18 22 23 11 17 21  9 10
    14  2  3  7 15 16  4  8 19 20 24 12 13  1  5  6 17 21  9 10 18 22 23 11
    13  1  5  6 17 21  9 10 18 22 23 11 14  2  3  7 15 16  4  8 19 20 24 12
    12 11 10  9  8  7  6  5  4  3  2  1 24 23 22 21 20 19 18 17 16 15 14 13
    11 12  8  4 10  6  7  3  9  5  1  2 23 24 20 16 22 18 19 15 21 17 13 14
    10  6  7  3 11 12  8  4 23 24 20 16  9  5  1  2 21 17 13 14 22 18 19 15
     9  5  1  2 21 17 13 14 22 18 19 15 10  6  7  3 11 12  8  4 23 24 20 16
     8  7  6  5 12 11 10  9 24 23 22 21  4  3  2  1 16 15 14 13 20 19 18 17
     7  8 12 24  6 10 11 23  5  9 21 22  3  4 16 20  2 14 15 19  1 13 17 18
     6 10 11 23  7  8 12 24  3  4 16 20  5  9 21 22  1 13 17 18  2 14 15 19
     5  9 21 22  1 13 17 18  2 14 15 19  6 10 11 23  7  8 12 24  3  4 16 20
     4  3  2  1 16 15 14 13 20 19 18 17  8  7  6  5 12 11 10  9 24 23 22 21
     3  4 16 20  2 14 15 19  1 13 17 18  7  8 12 24  6 10 11 23  5  9 21 22
     2 14 15 19  3  4 16 20  7  8 12 24  1 13 17 18  5  9 21 22  6 10 11 23
     1 13 17 18  5  9 21 22  6 10 11 23  2 14 15 19  3  4 16 20  7  8 12 24



Note that those are only labels for the elements as printing the whole permutations
would render the table useless since they wouldn't fit. 
You can find that for S_5 the table would not fit on the screen (or maybe it would if you had a big enough screen, or a small enough font).

You can also see a coloured Cayley table(the labels of the permutations are associated to colours):

=begin html

<p><center><img src="http://perlhobby.googlecode.com/svn/trunk/scripturi_perl_teste/cm-permutation/cpan/CM-Permutation/S_4_colour.PNG" /></center></p>

=end html



So if you want to see the meaning of the numbers(the permutations behind them) you can use str_perm()

    print $G1->str_perm;

    1 -> 3 2 1
    2 -> 2 3 1
    3 -> 2 1 3
    4 -> 3 1 2
    5 -> 1 3 2
    6 -> 1 2 3


=cut


#has n => (
    #isa => 'Int',
    #is  => 'rw',
    #default => undef,
    #required => 1,
#);

#has order => (
    #isa => 'Int',
    #is  => 'rw',
    #lazy => 1,
    #builder => '_builder_order',
#);

sub operation {
    my ($self,$a,$b) = @_;
    return $a*$b;
}

sub _builder_order {
        # n! is the order of this group
        # haven't tried to generate S_n above n=5 , but
        # n = 5 itself would actually generate a 720x720 matrix with 518400 cells,
        # in each cell will lie one permutation , so it will be slow, but computing the operation table isn't
        # really necessary..
        my $self = shift;
        reduce { $a * $b  } 1..$self->n;
}


#or Cayley table , however you want to call it
#has operation_table => (
    #isa => 'ArrayRef[ArrayRef[CM::Permutation]]',
    #is  => 'rw',
    #default => sub{[]},
#);

#has elements => (
    #isa => 'ArrayRef[CM::Permutation]',
    #is  => 'rw',
    #default => sub {[]},
#);

# todo -> cache permutations by string representations to make * faster






sub label_to_perm {
    my ($self,$label) = @_;
    validate_pos(
        @_,
        1,  # $self
        {   # $label
            type        => SCALAR ,
            callbacks   => {
                '1<= $label <= |G|', sub { my $v = shift; 1<=$v && $v <= $self->order }
            },
        }
    );

    my $where = $self->order - $label;
    return $self->operation_table->[0]->[$where];
}

# gets the label of the inverse of some permutation whos label is given as a parameter
sub get_inverse {
    # $self->order - $element becuse the elements are ordered differently because
    # A::Permutation enumrates them differently ...
    my ($self,$element) = @_;
    my $row = $self->order - $element;
    confess 'argument given is not in range of labels(which is 1..n! for S_n)'
        unless( $row>=0 && $row <= -1+$self->order );
    for my $column(0..-1+$self->order) {
        return $self->operation_table->[0]->[$column]->label if 
            $self->operation_table->[$row]->[$column]->label == $self->order;
    }
}


sub idempotent {
    #takes labels not perm at arguments
    my ($self,$element) = @_;
    my $i = $self->order - $element;

    confess 'argument given is not in range of labels(which is 1..n! for S_n)'
        unless( $i>=0 && $i <= $self->order );

    my $result = $self->operation_table->[$i]->[$i]->label;
    return $element == $result;
}


sub str_perm {
    my ($self) = @_;
    join(
        "\n",
        map {
            my $label   = $_->label;
            my $str     = "$_";
            "$label -> $str";
        } @{$self->elements}
    );
}

sub BUILD {
    my ($self) = @_;
};



# generate all permutations of the set {1..n}
sub _compute_elements {# should be a standard method name for all groups
	my ($self) = @_;
	sub {
		my $label = 0;
		my @permutations;
		my $p = new Algorithm::Permute([1..$self->n]);
		while (my @new_perm = $p->next) {
			my $new_one = CM::Permutation->new(@new_perm);
			$self->add_to_elements($new_one);
		};
	}
}




# coset of an element g \in G for the subgroup H<G is   gH = {g*h1,g*h2,...,g*hn} where n=|H|
sub left_coset {
    my ($self,$g,$H) = @_;
    # g must be in self
    # H must be subgroup of G(no way to check that implemented yet)

    return
    uniq
    map { $self->perm2label($_); }
    map { $g * $_ } 
    @{$H->elements};
}

sub right_coset {
    my ($self,$g,$H) = @_;

    return
    uniq
    map { $self->perm2label($_); }
    map { $_ * $g } 
    @{$H->elements};
}


#after writing this I checked CPAN and it seems that Algorithm::EquivalenceSets does
#something very similar , and then conj_classes is the same as(not as complexity, just functionality)
#
#equivalence_sets(
#   map {
#       my $a = $_;
#       map {
#           $a->conjugate($_)
#           ? [$a,$_]
#           : ()
#       } @{$self->elements}
#   } @{$self->elements}
#)
#
#this is more slow and would have been much smaller but I'm avoiding the overhead

#find conjugate classes (this could be factored out in CM::Algorithm::EquivalenceClasses as a Moose Role)


=head1 conj_classes()

find the conjugacy classes using the definition of conjugates.

=cut

sub conj_classes {
    my ($self) = @_;

    $self->elements->[$_]->group($self) 
    for 0..-1+@{$self->elements};



    confess 'no group on element in $self'
    unless $self->elements->[0]->group;

    my @Classes;# equivalence classes

    my @gelems = @{$self->elements};
    for my $to_place (@gelems) {
        my $where = -1;
        my $i_class;#class number
        for my $i_class(0..-1+@Classes) {
            next if @{$Classes[$i_class]} < 1;
            my $first_from_class = $Classes[$i_class]->[0];

            my $g = first {
                 $_*($to_place*($_**-1)) == $first_from_class
            } @gelems; # if there is a $g then $to_place and $first_from_class are conjugates
                       # first() will return undef if there is no such $g
            if($g) {# or we could do this as well which is slower -> if( $to_place << $first_from_class ){
                $where = $i_class;
                last;
            };
        };
        if($where < 0) { # haven't found a class for it, make room
            push @Classes,[];
            $where = ~~@Classes - 1 ;
        };
        push @{ $Classes[$where] } , $to_place
    }
    return @Classes;
}


=head1 conj_classes_fast()

finds the conjugacy classes of a group using cycle structure.
for example, the conjugacy classes of S_4 correspond to partitions of the number 4:

    (x)(x)(x)(x)
    (xx)(x)(x)
    (xx)(xx)
    (xxx)(x)
    (xxxxx)

so S_4 has 5 conjugacy classes.

=cut

# this will do the same thing(classify elements in conjugation classes) but
# using the fact that the conjugation classes correspond directly to the type of cycle
# decomposition that a permutation has
# for example S_4 has 5 classes
#
# (x)(x)(x)(x)
# (xx)(x)(x)
# (xx)(xx)
# (xxx)(x)
# (xxxxx)
# 
# where xs are elements of a cycle
#
# by comparison with conj_classes this(_fast) works much faster but requires additional knowledge
# about the group in question(symmetric group in this case) whereas conj_classes is generic enough to
# work for any group(which has a conjugation relation on it)
#

sub conj_classes_fast {
    my ($self) = @_;
    # a href where conjugacy classes will be kept inside arrayrefs in the values
    # and the keys will be labels of the form   "c1,c2,..,cn" where ci will be the lengths
    # of the cycles making up permutations belonging to that conjugacy class, the ci will be
    # sorted
    my $class_href = {};
    for my $p (@{ $self->elements }) {
        # how can I promote a CM::Permutation object to CM::Permutation::Cycle_Algorithm ?
        # (because they are related classes and it should be easy to inject in ISA something and
        # get to ::Cycle_Algorithm)
        
        # the label contains the sorted lengths of the cycles of $p separated by a comma
        my $label = join(",",
            (
                sort 
                map { ~~@{ $_->cycle_elements}; } 
                $p->get_cycles
            )
        );
        $class_href->{$label} = [] 
            unless $class_href->{$label};
        push @{$class_href->{$label}},
            $p;
#        print "($p) $label\n"; 
    };



    map {
        $class_href->{$_}
    }
    sort { $a < $b } keys %$class_href;
}


=pod

=head1 compute()

Computes the operation table.

=head1 draw_diagram($path)

This method will draw a diagram of the group to png to the given $path.
You can read the graph as follows.
An edge from X to Y with a label Z on it that means X * Z = Y where X,Y,Z are labels of permutations.

=cut




=head1 identity()

return the identity permutation for this group

=cut 

sub identity {
    my ($self) = @_;
    my $e = CM::Permutation->new(1..$self->n);
    first {
        $_ == $e;
    } @{ $self->elements };
}


# centralizer of an element in the group
# TODO: replace in all the code $self->order - index with index and fix all tests after that

=head1 centralizer(element)

this method returns the centralizer of an element in the group.
(note that the centralizer can be different in some particular subgroup)

=cut

sub centralizer {
    my ($self,$a) = @_;
    my $i=
    $a->label
    ? $self->order - $a->label
    : $self->order - $self->perm2label($a);

    my @central;
    for my $j (0..-1+$self->order) {
        
        push @central, $self->operation_table->[$j]->[0]
            if( $self->operation_table->[$i]->[$j]->label ==
                $self->operation_table->[$j]->[$i]->label
            );
    };

    return @central;
}


=head1 center()

returns the center of the group

=cut 

sub center {
    my ($self) = @_;
    my @result;
    for my $g ( @{$self->elements} ) {
        my @centralizer = $self->centralizer($g);
#        say "($g) has ".scalar(@centralizer)." elements in centralizer";
        push @result,$g
            if(scalar(@centralizer)==$self->order)
    };
    return @result;
}


=head1 normal_subgroups()

computes the normal subgroups of a group of permutations

=cut

#################################################################################################
# normal subgroups are unions of conjugacy classes(this can be proved) so according
# to equation class their order must be the sum of orders of conjugacy classes 
# and of course their order must divide the order of the group by Lagrange's theorem
# (
# as a test we'll check that A_5 has no normal subgroups(aka simple group) but that S_4 does have normal subgroups
# also a test will be done if any subgroup of index 2( [G:H] = 2) is normal
# )
#################################################################################################

sub normal_subgroups {
    my ($self) = @_;
    my @classes = $self->conj_classes_fast;
    @classes = grep { !grep { $_ == $self->identity  } @{$_} } @classes; # take class with identity out
    my @nsubgroups;

    # my $max = -1 + (2**@classes);# -1 because we include the identity in the subgroup every time(we'll add it back later)
    my $vec = Bit::Vector->new(scalar @classes);

    while(!$vec->increment) {#stop when we have a carry(->increment returns something) because that's when we overflowed and it's clear that we iterated over all subsets

        # enumerate all bitstrings of length scalar @classes as there is a correspondence
        # between these bitstrings and the subsets of some set(the set of all conjugacy classes here)
        my @subset = map {
            $vec->contains($_);
        } 0..-1+@classes;
        
        print $vec->to_Bin."\n";
        
        my @N = 
        map { @{ $classes[$_] } }
        grep{ $subset[$_]  }
        (0..-1+@classes);
        next if @N+1 == $self->order; # exclude the whole group G
        do {
            print "order ".(1+@N)." \n";
            push @N,$self->identity;#put indentity back
            push @nsubgroups,\@N
        }
            if( $self->order % (1+@N) == 0); # +1 because we add back the identity before checking order
    };
    return @nsubgroups;
}



=head1 dimino(@S)

given a set of generators @S , Dimino's algorithm(see [2] for details) enumerates all elements of the subgroup <@S> generated by the set @S

=cut
sub dimino {
    # Dimino's algorithm for computing the elements of a group given it's generators
    #
    # for details check G. Butler - Fundamental Algorithms on Permutation Groups pages 14-22


    # the first position of @S and @elements is filled to make elements start from index 1

    my ($self,@S) = @_;
    @S            = ($self->identity,@S);
    my @elements  = ($self->identity,$self->identity);
    my $order     = 1;
    my $g         = $S[1];

    sub not_in{ # returns true if $elem is not to be found in the elements @$aref
        my ($elem,$aref) = @_;
        return all { $_ != $elem } @{$aref};
    }; # aparrently  $element !~~ @array didn't work(although == is implemented for permutations)
       # so had to write something to test if a permutation belongs to a set or not

    while($g!=$self->identity) {
        $order++;
        push @elements,$g;
        $g = $g * $S[1];
    };

    for my $i (2..~~@S-1) {
        if( not_in($S[$i],\@elements) ) { # next generator not redundant
            my $previous_order  = $order;
            $elements[++$order] = $S[$i];
            for my $j (2..$previous_order) {
                $elements[++$order] = $elements[$j] * $S[$i];
            };
            my $rep_pos = $previous_order + 1;
            while(1){
                for my $s (@S[1..$i]) { # for each s in S_i (where S_i is the truncated S to first i elements)
                    my $elt = $elements[$rep_pos] * $s;
                    if( not_in($elt,\@elements) ){ # adding the right coset of $elt
                        $elements[++$order] = $elt;
                        for my $j(2..$previous_order) {
                            $elements[++$order] = $elements[$j] * $elt;
                        }
                    }
                };
                $rep_pos += $previous_order;
                last if $rep_pos > $order;
            }
        }
    };
    shift @elements; # take out the dummy identity permutation we put at first for indexes to start at 1 in the begining
    return @elements;
}


# elements that fix $x
sub stabilizer {
	my ($self,@fixed) = @_;

	grep 
	{ 
		my $elem = $_;
		reduce { $a & $b }
		(1,
			map { $elem->perm->[$_] == $_}
			(@fixed)
		);
	} 
	@{$self->elements};
}


=head1 cayley_digraph($path,$generators_arrayref)

computes the Cayley graph of a group given the generators.

for example the graph for S_4 with generators the transpositions (1,2) ; (2,3) ; (3,4) looks like this:



=begin html

<p><center><img src="http://perlhobby.googlecode.com/svn/trunk/scripturi_perl_teste/cm-permutation/cpan/CM-Permutation/Cayley_S_4.gif" /></center></p>

=end html

Fortunately this particular cayley graph can be arranged as a truncated octahedron and it's one of the 13 Archimedian solids , 
it's also called a permutahedron.

L<http://en.wikipedia.org/wiki/Truncated_octahedron>

L<http://en.wikipedia.org/wiki/Cayley_graph>
=cut

# polyhedrons generated as an arrangement of the cayley graph are called permutahedra


=pod

=head1 THEOREMS AS TESTS

Some theorems and properties of groups or permutations are used as tests.

=head1 BIBLIOGRAPHY

    [1] Joseph Rotman   - An Introduction to the Theory of Groups
    [2] Gregory Butler  - Fundamental Algorithms for Permutation Groups (Lecture Notes in Computer Science)
    [3] http://www.jaapsch.net/puzzles/cayley.htm

=head1 AUTHOR

Stefan Petrea, C<< <stefan.petrea at gmail.com> >>

=cut

1;
