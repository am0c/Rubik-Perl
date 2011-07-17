#==================================================================================================================================
package Rubik::Cubie; # small cubie that composes the big one
use Moose;
use OpenGL; 


=head1 NAME

Rubik::Cubie


=head1 DESCRIPTION

This is used for displaying the Rubik's cube

=cut




has view => (
    isa => 'Rubik::View',
    is  => 'rw',
    required=> 1,
);


# the position of the cubie
has pos => (
    isa => 'ArrayRef[Any]',
    is  => 'rw',
    required=>0,
    default=> sub { [0,0,0] },
);

has colours => (
    isa     => 'ArrayRef[ArrayRef[Any]]', # Aref[Aref[Float]] actually ..
    is      => 'rw',
    default => sub{ 
        [
            [1 , 0 , 0] , #Right
            [1 , 0 , 1] , #Down
            [0 , 0 , 1] , #Left
            [1 , 1 , 0] , #Up
            [0 , 1 , 0] , #Front
            [0 , 1 , 1] , #Back
        ];
    },
);

has faces => (
    isa => 'ArrayRef[ArrayRef[Int]]',
    is  =>'rw',
    default => sub {
        [
            [0, 1, 2, 3,], 
            [3, 2, 6, 7,], 
            [7, 6, 5, 4,], 
            [4, 5, 1, 0,],
            [5, 6, 2, 1,], 
            [7, 4, 0, 3,], 
        ]
    },
);

sub Draw {
    my($self) = @_;
    my $s = 1;


=head1 DESCRIPTION

Labels for a cubie ( there are 3x3x3 in the rubik's cube )
this cube will help with understanding what's going on in the code, the numbers are the indices of the vertices inside the @v array below


             _________________________
            /1_____________________ 5/|
           / / ___________________/ / |
          / / /| |               / /  |
         / / / | |              / / . |
        / / /| | |             / / /| |
       / / / | | |            / / / | |
      / / /  | | |           / / /| | |
     / /_/__________________/ / / | | |
    /________________________/ /  | | |
    |0______________________4| |  | | |
    | | |    | | |_________| | |__| | |
    | | |    | |___________| | |____| |
    | | |   / /2___________| | |_  6 /
    | | |  / / /           | | |/ / /
    | | | / / /            | | | / /
    | | |/ / /             | | |/ /
    | | | / /              | | ' /
    | | |/_/_______________| |  /
    | |____________________| | /
    |3______________________7|/

=cut




    # veritces of cube
    my @v = (
        [    -1 +$self->pos->[0], -1 +$self->pos->[1], -1 +$self->pos->[2],], 
        [    -1 +$self->pos->[0], -1 +$self->pos->[1], 1  +$self->pos->[2],],
        [    -1 +$self->pos->[0], 1  +$self->pos->[1], 1  +$self->pos->[2],],
        [    -1 +$self->pos->[0], 1  +$self->pos->[1], -1 +$self->pos->[2],],
        [    1  +$self->pos->[0], -1 +$self->pos->[1], -1 +$self->pos->[2],],
        [    1  +$self->pos->[0], -1 +$self->pos->[1], 1  +$self->pos->[2],],
        [    1  +$self->pos->[0], 1  +$self->pos->[1], 1  +$self->pos->[2],],
        [    1  +$self->pos->[0], 1  +$self->pos->[1], -1 +$self->pos->[2],]
    );


     $self->view->Draw(
         GL_QUADS,
         sub {
             for(my $i=0;$i<6;$i++){
				 # the 6 facelets of a cubie are coloured based on the property
                 glColor3f(@{$self->colours->[$i]});


                 for(my $j=0;$j<4;$j++){
                     my $k=$self->faces->[$i]->[$j];
                     glVertex3f(@{$v[$k]});
                 }

             }
         }
     );
}

=head1 AUTHOR

Stefan Petrea, C<< <stefan.petrea at gmail.com> >>

=cut

1;
