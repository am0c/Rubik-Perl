package Rubik::Model;
use Moose;
use lib './lib';
use CM::Rubik;
use Rubik::Cubie;
use List::AllUtils qw/reduce/;


=head1 NAME

Rubik::Model


=head1 DESCRIPTION

This module is responsible for persisting the state of the Rubik's cube between rotations of sides , and also
it maps the set 1..54 to the facelets of the cube.


=head1 Internal structure

There is a 3x3x3 array called C that stores the cubies

C[x][y][z] with x,y,z ranging in 0,1,2


It will contain what cube is in that position 

A rotation of the front face at 90 degrees clockwise will be like this


    0 , 1 , 2       6 , 3 , 0

    3 , 4 , 5  ===> 7 , 4 , 1

    6 , 7 , 8       8 , 5 , 2


The following correspondence between C and the faces of the cube :

          C[x][y][0]  is Front
          C[x][y][2]  is Back

          C[x][0][z]  is Up
          C[x][2][z]  is Down

          C[0][y][z]  is Left
          C[2][y][z]  is Right

Each of the cubies will have 1,2,3 facelets visible depending on wether it is a center, a edge or a corner.

=cut



has rubik => (
    isa => 'CM::Rubik',
    is  =>'rw',
    default => sub {
        CM::Rubik->new();
    },
);


has view => (
    isa => 'Rubik::View',
    is  => 'rw',
    required => 1,
);

has distance => (
    isa => 'Any',
    is  => 'rw',
    default=> -2.1,
);

has sense   => (
    isa =>'Int',
    is  =>'rw',
    default => 1,
);


has cubies => (
    isa => 'Any',
    is  => 'rw',
    default => sub {
        my ($self) = @_;
        my $C=[];
        my $d = $self->distance; # distance between centers of cubies
        for my $x1 (0..2) {
            for my $y1 (0..2) {
                for my $z1 (0..2) {
                    $C->[$x1]->[$y1]->[$z1] = Rubik::Cubie->new({view=>$self->view});
                    $C->[$x1]->[$y1]->[$z1]->pos([
                        $d * ($x1 - 1),
                        $d * ($y1 - 1),
                        $d * ($z1 - 1)
                        ]);
                }
            }
        };
        $C;
    },
    required => 0,
    lazy => 1,
);

sub scramble {
    my ($self) = @_;
    my @pmoves = qw/F B U D R L/;

    # first element is identity since that's the solved state and the other 100 are all all random moves

    # it's faster to multiply out permutations then apply them using move_perm than to apply repeated permutations...
    # because under the hood colours are permuted etc..
    $self->move_perm(
                    reduce { $a * $self->rubik->$b }  ( 
                                                            $self->rubik->I ,
                                                            (
                                                                map {  $pmoves[$_] } 
                                                                (
                                                                    map { int(rand(6)) }
                                                                    (1..100)
                                                                )
                                                            )
                                                      )
                    );
}


# NOTE : when rotating the cubies I don't actually have to update @C so that the cubies really are in new places, the only thing
# I need to do is apply the permutations to the faces and change colours.
#
#                 .----|-----|----.
#                 |37  |38   |39  |
#                 |    |     |    |
#                 |----|-----|----|
#                 |40  |41   |42  |  <= Back
#    Left         |    |     |    |
#     ||          |----|-----|----|
#     \/          |43  |44   |45  |
#                 |    |     |    |
#                /\----|-----|----/\
#.----|-----|----\/----|-----|----\/----|-----|----\/----|-----|----.
#|48  |51   |54  ||    |     |    ||36  |33   |30  ||18  |15   |12  |
#|    |     |    ||21  |24   |27  ||    |     |    ||    |     |    |
#|----|-----|----||----|-----|----||----|-----|----||----|-----|----|
#|47  |50   |53  ||20  |23   |26  ||35  |32   |29  ||17  |14   |11  | <=== Down
#|    |     |    ||    |     |    ||    |     |    ||    |     |    |
#|----|-----|----||----|-----|----||----|-----|----||----|-----|----|
#|46  |49   |52  ||    |     |    ||34  |31   |28  ||16  |13   |10  |
#|    |     |    ||19  |22   |25  ||    |     |    ||    |     |    |
#.----|-----|----/\----|-----|----/\----|-----|----/\----|-----|----.
#                \/----|-----|----\/           
#          _//    |7   |8    |9   |             /\
#         / /|    |    |     |    |             ||
#        / / /    |----|-----|----|             Right
#         /       |4   |5    |6   |
#        /        |    |     |    |  <== Front
#       /         |----|-----|----|
#     Up          |1   |2    |3   |
#                 |    |     |    |
#                 .----|-----|----.




# we're mapping the set [1..54] onto each of the visible faces of the 3x3x3 cubies that compose the
# rubik's cube, this is what this function does. I'm sure it could have more elegantly written with a good
# formula to map them ... however this will do for the moment

sub getColor {
    my($self,$n,$c) = @_;
    my $ret;
    if(     $n >= 0 && $n <= 8 ) {#Front
        $n-=0;
        # 4 because that's the face on the outside of the cubie that is seen
        # 0 because the Front has z = 0 in as the z coordinate
        $ret = $self->cubies->[ $n % 3 ][ $n / 3 ][ 0 ]->colours->[4];
    }elsif( $n >= 36&& $n <= 44) {#Back
        $n-=36;
        $ret = $self->cubies->[ $n % 3 ][ $n / 3 ][ 2 ]->colours->[5];
    }elsif( $n >= 45&& $n <= 53) {# Left
        $n-=45;
        $ret = $self->cubies->[0][ $n / 3 ][ $n % 3 ]->colours->[2];
    }elsif( $n >= 27&& $n <= 35) {# Right
        $n-=27;
        $ret = $self->cubies->[2][ $n / 3 ][ $n % 3 ]->colours->[0];
    }elsif( $n >=  9&& $n <= 17) {# Down
        $n-=9;
        $ret = $self->cubies->[$n/3][ 0 ][ $n % 3 ]->colours->[1];
    }elsif( $n >= 18&& $n <= 26) {# Up
        $n-=18;
        $ret = $self->cubies->[$n/3][ 2 ][ $n % 3 ]->colours->[3];
    };
    return $ret;
}

sub setColor { # parameter will be a number in [0..53] and you'll set the colour of that face of a cubie
    # Right is with x = 2 , Front is with  z = 0
    my($self,$n,$c) = @_;
    if(     $n >= 0 && $n <= 8 ) {#Front
        $n-=0;
        # 4 because that's the face on the outside of the cubie that is seen
        # 0 because the Front has z = 0 in as the z coordinate
        $self->cubies->[ $n % 3 ][ $n / 3 ][ 0 ]->colours->[4] = $c;
    }elsif( $n >= 36&& $n <= 44) {#Back
        $n-=36;
        $self->cubies->[ $n % 3 ][ $n / 3 ][ 2 ]->colours->[5] = $c;
    }elsif( $n >= 45&& $n <= 53) {# Left
        $n-=45;
        $self->cubies->[0][ $n / 3 ][ $n % 3 ]->colours->[2] = $c;
    }elsif( $n >= 27&& $n <= 35) {# Right
        $n-=27;
        $self->cubies->[2][ $n / 3 ][ $n % 3 ]->colours->[0] = $c;
    }elsif( $n >=  9&& $n <= 17) {# Bottom
        $n-=9;
        $self->cubies->[$n/3][ 0 ][ $n % 3 ]->colours->[1] = $c;
    }elsif( $n >= 18&& $n <= 26) {# Up
        $n-=18;
        $self->cubies->[$n/3][ 2 ][ $n % 3 ]->colours->[3] = $c;
    };
}


sub move_perm { #move according to a given permutation
    my ($self,$perm) = @_;
    confess "argument not CM::Permutation" unless $perm->isa('CM::Permutation');
    #confess 'only moves are F,B,U,D,R,L' unless $move =~ /^[FBUDRL]$/;

    my @old_colors = map { $self->getColor($_-1) } (1..54);
    my @new_colors = $perm->apply( @old_colors ); # apply permutation to them and put them in new_colors

    confess "not the same number of colours returned" unless ~~@new_colors == ~~@old_colors;

    $self->setColor($_,$new_colors[$_]) for (0..-1+@new_colors);
}


sub valid {
    my ($self,$move) = @_;
    return $move =~ /^[FBUDRL]i?$/;
}


sub move {
    # because games are not a simulation but are meant to be fun, we don't actually move the cubies, we just
    # permute the faces of the cubies so as to give the illusion that the rotation has really occured

    my ($self,$move) = @_;
    confess 'only moves are F,B,U,D,R,L and their inverses' unless $self->valid($move);
    


    my @old_colors = map { $self->getColor($_-1) } (1..54);
    my @new_colors = $self->rubik->$move->apply( @old_colors ); # apply permutation to them and put them in new_colors

    confess "not the same number of colours returned" unless ~~@new_colors == ~~@old_colors;

    $self->setColor($_,$new_colors[$_]) for (0..-1+@new_colors);
}

sub BUILD {
    my ($self) = @_;
    $self->view->model($self);
}


=head1 AUTHOR

Stefan Petrea, C<< <stefan.petrea at gmail.com> >>

=cut



1;

#==================================================================================================================================

