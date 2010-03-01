package Rubik::View;
use Moose;
use OpenGL;



=head1 NAME

Rubik::View - The view module for Rubik's cube simulator

=head1 DESCRIPTION

This module is responsible for using OpenGL to render the cube. It's also responsible for storing positions of
vertices and current rotation angle and current move and the width/height of the viewport.

=cut


# what face is currently rotated
has currentmove => (
        isa=> 'Str',
        # is => 'rw', #because it's syntax suggar for reader => "attrname" , writer => 'attrname' and I'm not using that because I made my own
        default=> '',
        writer=> 'set_currentmove',
        reader=> 'get_currentmove',
);


# reimplementing getter/setter here
sub currentmove {
    my ($self,$val) = @_;
    if($val) {
        $self->set_currentmove($val);
        $val =~ /(.)$/;

        # if the current move is inverse then change the sense of rotation
        $self->model->sense(
            $1 eq 'i'
            ?-1
            :+1
        );

    } else {
        return $self->get_currentmove;
    };
};


# angle at which it's rotated now
has spin     => (
        isa=> 'Int',
        is => 'rw',
        default=> 0,
);

has width  => (
    isa => 'Int',
    is  =>'rw',
    default => 400
);

has height  => (
    isa => 'Int',
    is  =>'rw',
    default=> 400
);

has model => (
    isa => 'Rubik::Model',
    is  => 'rw',
    required => 0,
);


sub Draw {
    my ($self,$type,$sub) = @_; # type is what we want to draw, GL_QUAD , GL_POLYGON etc..
    glBegin($type);
    $sub->();
    glEnd();
}

sub Reshape {
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();

    # first parameter is eye position
    # second is center position
    # third is the direction the camera is looking at

    gluPerspective(1000.0, 1.0 , 1.0, 30.0); 
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();


    # I think gluLookAt doesn't work at all here and there's supposed to be only one projection, and that should be
    # GL_MODELVIEW , but it doesn't really work ...
    gluLookAt(120,100,100,
              0  ,  0,  0,
              -1 , -1, -1,
          );
    glLoadIdentity();
}

sub Init {
    my ($self) = @_;
    glpOpenWindow(width => $self->width, height => $self->height,
        attributes => [GLX_RGBA,GLX_DOUBLEBUFFER]);
    glClearColor(0,0,0,1);
    glShadeModel (GL_FLAT);
    $self->Reshape();
    glDisable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_LIGHT0);
    glLoadIdentity();

# Thu 18 Feb 2010 06:01:19 PM EST
# apply these to object... or camera ?
# anyway the camera apparently doesn't want to move how it's supposed to with gluLookAt so I'm using this as a substitute
#
# but apparently http://www.opengl.org/resources/faq/technical/viewing.htm  is a very good source of information
    glTranslatef (1,7,-20);
    glRotatef(45,0,1,0);
}

sub DrawFrame {
    my ($self,$sub) = @_;# sub is the sub called for drawing the frame
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glPushMatrix();
    #$sub->($self->currentmove);
    $self->rotate_face;
    glPopMatrix();
    glFlush();
    glXSwapBuffers;
}


sub rotate_face {
    my($self) = @_;

    my $face = $self->currentmove;

    my @p = (0,1,2); # coordinates inside @C

    my @to_rotate;


    # the i after a move is optional, it means inverse,hence the regexes
    for my $x (@p) {
        for my $y (@p) {
            for my $z (@p) {
                if(     
                        ($face =~ /Fi?/ && $z==0 ) ||
                        ($face =~ /Bi?/ && $z==2 ) ||

                        ($face =~ /Li?/ && $x==0 ) ||
                        ($face =~ /Ri?/ && $x==2 ) ||

                        ($face =~ /Di?/ && $y==0 ) ||
                        ($face =~ /Ui?/ && $y==2 )
                ) {
                    #print "$x $y $z\n";
                    push @to_rotate,[$x,$y,$z];
                    next;
                };
                $self->model->cubies->[$x]->[$y]->[$z]->Draw();
            }
        }
    };



    # rotation vectors associated to each of the moves
    my $rot_vec = {
        "F"         => [0  , 0  , -1 ] ,
        "B"         => [0  , 0  , +1 ] ,
        "D"         => [0  , -1 , 0  ] ,
        "U"         => [0  , +1 , 0  ] ,
        "L"         => [-1 , 0  , 0  ] ,
        "R"         => [+1 , 0  , 0  ] ,
    };

    $rot_vec->{$_.'i'} = $rot_vec->{$_}  for qw/F B D U L R/; # for inverses

    
    #my @dbg = @{$rot_vec->{$face}};
    #print "spin = ".$view->spin." rotvector: @dbg \n";
    #glRotatef(90,0,1,0);
    glRotatef( ( $self->model->sense <=> 0 ) * $self->spin, @{$rot_vec->{$face}}); # the sense is established each time you set a currentmove

    for my $pair (@to_rotate) {
        my ($x,$y,$z) = @$pair;
        $self->model->cubies->[$x]->[$y]->[$z]->Draw();
    }
}

#==================================================================================================================================


=head1 AUTHOR

Stefan Petrea, C<< <stefan.petrea at gmail.com> >>

=cut

1;
