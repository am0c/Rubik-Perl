package Rubik::Model;
use strict;
use warnings;
use Moose;
use lib './lib';
use CM::Rubik;
use Rubik::Cubie;
#use Data::Match;
use List::AllUtils qw/reduce firstidx/;
use overload  '""' => 'stringify'; 


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
    lazy     => 1,
);

has state       => (
	isa      => 'CM::Permutation',
	is       => 'rw',
	default  => sub { 
		my ($self) = @_;
		$self->rubik->I ;
	},
	required => 0,
	lazy     => 1,
);


# centers are invariant to this scrambling 
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



# returns if facelets @many should be on the same face
sub should_be_same_face {
	my ($self,@many) = @_;
	confess "at least 2 arguments needed" unless @many >= 2;
	reduce { $a && $b }
	map {
		$self->should_be_belongs_to($many[$_   ] ) eq
		$self->should_bebelongs_to($many[$_+1 ] );
	} (0..@many-2);
}


# returns if facelets @many are on the same face
sub same_face {
	my ($self,@many) = @_;
	confess "at least 2 arguments needed" unless @many >= 2;
	reduce { $a && $b }
	map {
		$self->belongs_to($many[$_   ] ) eq
		$self->belongs_to($many[$_+1 ] );
	} (0..@many-2);
}


# returns the face to which a facelet should belong to

sub should_belong_to {
	my ($self,$n) = @_;
	return 'R' if $n >= 28 && $n <=36;
	return 'F' if $n >= 1  && $n <=9;
	return 'D' if $n >= 10 && $n <=18;
	return 'B' if $n >= 37 && $n <=45;
	return 'L' if $n >= 46 && $n <=54;
	return 'U' if $n >= 19 && $n <=27;
}

# the face that facelet $n belongs to is the should_belong_to of the index of the position which indicates to it
# (it sounds weird, but just think a moment about it ...)
# TODO:add a more clear explanation

sub belongs_to {
	my ($self,$n) = @_;
	$self->should_belong_to(

		firstidx 
		{$self->state->perm->[$_] == $n } 
		(1..54)

	);
}

sub is_center {
	my ($self,$n) = @_;
	my @a = (5,50,41,32,14,23);
	return $n ~~ @a;
}

sub is_corner   {
	my ($self,$n) = @_;
	my @a = (
		4 , 8 , 5 , 4 , 5 , 2 , 4 , 6 ,
		2 , 1 , 2 , 7 , 2 , 5 , 1 , 9 ,
		7 , 9 , 3 , 1 ,
		3 , 6 , 3 , 0 , 2 , 8 , 3 , 4 ,
		1 , 8 , 1 , 2 , 1 , 0 , 1 , 6 ,
		3 , 7 , 3 , 9 , 4 , 3 , 4 , 5
	);
	return $n ~~ @a;
}

sub is_edge	{
	my ($self,$n) = @_;
	return !($self->is_center($n)||$self->is_corner($n));
}


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
    
    $self->state($self->state * $perm);
}



sub move_until {
	my ($self,$what_move,$until) = @_;
	while(1) {
		$self->move->$what_move;
		last if $until->();
	};
}



sub solve_cross {
	my ($self) = @_;

	# 14 is the center of the down face .. which we want to make a cross on
	
}

sub valid {
    my ($self,$move) = @_;
    return $move =~ /^[FBUDRL]i?$/;
}

sub valid_moves {
	my ($self,$moves) = @_;
	return $moves =~ /^([FBUDRL]i?)+$/;
}

sub moves {
    my ($self,$moves) = @_;

    confess "parameter moves undefined or empty" unless $moves;
    confess "invalid move syntax" unless $self->valid_moves($moves);

    while(my ($move) = $moves =~ s/^([FBUDRL]i?)//) {
	    $self->move($move);
    };

}


sub move {
    # because games are not perfect simulations but are meant to be fun, we don't actually move the cubies, we just
    # permute the faces of the cubies so as to give the illusion that the rotation really persisted

    my ($self,$move) = @_;
    confess 'only moves are F,B,U,D,R,L and their inverses' unless $self->valid($move);
    

    my $pmove = $self->rubik->$move;# permutation associated with this move

    my @old_colors = map { $self->getColor($_-1) } (1..54);
    my @new_colors = $pmove->apply( @old_colors ); # apply permutation to them and put them in new_colors

    confess "not the same number of colours returned" unless ~~@new_colors == ~~@old_colors;

    $self->setColor($_,$new_colors[$_]) for (0..-1+@new_colors);

    $self->state($self->state * $pmove);
}

sub stringify {
	my ($self) = @_;
	my $p = $self->state;
	return "$p";
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

