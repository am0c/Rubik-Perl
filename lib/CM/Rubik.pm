package CM::Rubik;
use strict;
use warnings;
use Moose;
use CM::Permutation;
use List::AllUtils qw/reduce/;

# we'll be modelling Rubik's cube here

=pod

=head1 NAME

CM::Rubik - Rubik's cube

=head1 DESCRIPTION

The Rubik's cube is known primarily as a toy puzzle, which has associated the Rubik's cube group.
Its generators are the permutations that correspond to clockwise 90 degrees rotations of each of its faces,let's call these: F R B L D U.
These are permutations of the set {1..54} if we consider the centers of the faces also(although these are fixed points under the permutations).

The order of the group is 43_252_003_274_489_856_000 , yeah, that's :

Forty-three quintillion two hundred fifty-two quadrillion three trillion two hundred seventy-four billion four hundred eighty-nine  
million eight hundred fifty-six thousand. But at least it's not infinite right ? :)

There's also a simulator of Rubik's cube written using OpenGL and Perl, using CM::Permutation and CM::Rubik in order to implement the 
logic of the rotations:



=head1 comb(string)

This will give you the permutation which results from multiplying the sequence of transformations in the string.
It returns a CM::Permutation object.
OBS: you can also find the order(the number of times you make those moves until the cube returns to the position before you started them)
using the order() method on the result, so for example:

	my $r = CM::Rubik->new;
	print $r->comb('FURBL');

	252





=begin html

<p><center>

<img src="http://perlhobby.googlecode.com/svn/trunk/scripturi_perl_teste/cm-permutation/cpan/CM-Permutation/rubik1.png" />
<img src="http://perlhobby.googlecode.com/svn/trunk/scripturi_perl_teste/cm-permutation/cpan/CM-Permutation/rubik2.png" />
<img src="http://perlhobby.googlecode.com/svn/trunk/scripturi_perl_teste/cm-permutation/cpan/CM-Permutation/rubik3.png" />

</center></p>

=end html

To understand where the permutations came from I used the following unfolded version of the cube, the numbers are labels
for the facelets:


                     .----|-----|----.
                     |37  |38   |39  |
                     |    |     |    |
                     |----|-----|----|
                     |40  |41   |42  |  <= Back
        Left         |    |     |    |
         ||          |----|-----|----|
         \/          |43  |44   |45  |
                     |    |     |    |
                    /\----|-----|----/\
    .----|-----|----\/----|-----|----\/----|-----|----\/----|-----|----.
    |48  |51   |54  ||    |     |    ||36  |33   |30  ||18  |15   |12  |
    |    |     |    ||21  |24   |27  ||    |     |    ||    |     |    |
    |----|-----|----||----|-----|----||----|-----|----||----|-----|----|
    |47  |50   |53  ||20  |23   |26  ||35  |32   |29  ||17  |14   |11  | <=== Down
    |    |     |    ||    |     |    ||    |     |    ||    |     |    |
    |----|-----|----||----|-----|----||----|-----|----||----|-----|----|
    |46  |49   |52  ||    |     |    ||34  |31   |28  ||16  |13   |10  |
    |    |     |    ||19  |22   |25  ||    |     |    ||    |     |    |
    .----|-----|----/\----|-----|----/\----|-----|----/\----|-----|----.
                    \/----|-----|----\/           
              _//    |7   |8    |9   |             /\
             / /|    |    |     |    |             ||
            / / /    |----|-----|----|             Right
             /       |4   |5    |6   |
            /        |    |     |    |  <== Front
           /         |----|-----|----|
         Up          |1   |2    |3   |
                     |    |     |    |
                     .----|-----|----.



=cut
#
# #how to make the unfolded version of the cube:
#
# REM: I used vim to make one 3x3 block, then copy pasted using visual block <c-v>
# then used this mappin to change numbers in it without altering the rest of the borders
# :map \x "xciw<c-r>=repeat(" \<lt>left>",strlen(@x))<cr><esc><RIGHT>:startreplace<cr>
#
#


# this will be used in future versions to store the current state of the cube depending on the transformations used
# (Currently not in use)
has config => (
    isa     => 'CM::Permutation',
    is      => 'rw',
    default => sub{ CM::Permutation->new(1..54); },
);

# F,R,B,L,D,U are rotations of the appropriate faces by 90 degrees clockwise
#
# there are some more notations that fit the following grammar  <face>(2|`|epsilon)
#
# ` means invert counter-clockwise, 2 means clockwise 2 times


sub p {
    my ($self,@args) = @_;
    return CM::Permutation->new(@args);
}

sub pc {
    my ($self,@args) = @_;
    return CM::Permutation::Cycle->new(@args);
}


sub rotate_face {
    #permutation that rotate clockwise arguments if the arguments are structured as lines of the face consecutively
    my ($self,@args) = @_;

    @args = (0,@args);

    # important to notice that 4 is a fixed point in this permutation
    my $i = 1;
    return
    $self->p({
            0=>0,
            map { ($args[$i++] => $args[$_]) } 
            (
                7 , 4 , 1 ,

                8 , 5 , 2 ,

                9 , 6 , 3
            )
     });
}


sub I {#the identity state ... the solved state of the cube
    my ($self) = @_;
    return $self->p(1..54);
}

# the David Singmaster notation for the moves F B U D R L



# inverse transformations
sub Bi { my ($self) = @_ ;  $self->B ** -1 };
sub Fi { my ($self) = @_ ;  $self->F ** -1 };
sub Ui { my ($self) = @_ ;  $self->U ** -1 };
sub Di { my ($self) = @_ ;  $self->D ** -1 };
sub Li { my ($self) = @_ ;  $self->L ** -1 };
sub Ri { my ($self) = @_ ;  $self->R ** -1 };

sub B {
    my ($self) = @_;
    $self->rotate_face(
        37..45
    )*
    $self->p({
            54=>27,
            51=>24,
            48=>21,

            12=>54,
            15=>51,
            18=>48,

            30=>12,
            33=>15,
            36=>18,

            27=>30,
            24=>33,
            21=>36,
    });
}



sub F{
    my ($self) = @_;
    $self->rotate_face(
        7,8,9,
        4,5,6,
        1,2,3,
    )*
    $self->p({
            34=>19,
            31=>22,
            28=>25,

            16=>34,
            13=>31,
            10=>28,

            46=>16,
            49=>13,
            52=>10,

            19=>46,
            22=>49,
            25=>52,
    });
}


sub R {
    my ($self) = @_;
    $self->rotate_face(
        36,33,30,
        35,32,29,
        34,31,28,
    )*
    $self->p({
            45=>25,
            42=>26,
            39=>27,

            18=>45,
            17=>42,
            16=>39,

            3=>18,
            6=>17,
            9=>16,

            25=>3,
            26=>6,
            27=>9,
    });
}

sub L {
    my ($self) = @_;
    $self->rotate_face(
        54,53,52,
        51,50,49,
        48,47,46
    )*
    $self->p({
            7=>21,
            4=>20,
            1=>19,

            10=>7,
            11=>4,
            12=>1,

            37=>10,
            40=>11,
            43=>12,

            21=>37,
            20=>40,
            19=>43,
    });
}



sub D{
    my ($self) = @_;
    $self->rotate_face(
        19..27
    )*
    $self->p({
        36=>43,
        35=>44,
        34=>45,
        
        9=>36,
        8=>35,
        7=>34,
        
        52=>9,
        53=>8,
        54=>7,

        43=>52,
        44=>53,
        45=>54,
    });
}


sub U {
    my ($self) = @_;
    $self->rotate_face(
        18,15,12,
        17,14,11,
        16,13,10
    )*
    $self->p({
        39=>28,
        38=>29,
        37=>30,

        48=>39,
        47=>38,
        46=>37,

        1=>48,
        2=>47,
        3=>46,

        28=>1,
        29=>2,
        30=>3,
    });
}


sub comb { # combination of a series of moves
    my ($self,$moves) = @_;

    confess "parameter moves undefined or empty" unless $moves;

    if(my ($noway) = $moves =~ /([^FBLRUD])/) {
        confess "move $noway not allowed";
    };

    $moves =~ s/^(.)//;
    my $first = $self->$1;

    return reduce { $a * $self->$b } ($first,split(//,$moves));
}

1;
