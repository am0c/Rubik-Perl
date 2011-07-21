package Rubik::View;
use Moose;
use OpenGL qw(:all);
use Time::HiRes qw(usleep);
use feature ':5.10';



=head1 NAME

Rubik::View - The view module for Rubik's cube simulator

=head1 DESCRIPTION

This module is responsible for using OpenGL to render the cube. It's also responsible for storing positions of
vertices and current rotation angle and current move and the width/height of the viewport.

=cut

use constant ESCAPE => 37;


# what face is currently rotated
has currentmove => (
        isa     => 'Str',
        # is    => 'rw', #because it's syntax suggar for reader => "attrname" , writer => 'attrname' and I'm not using that because I made my own
        default => '',
        writer  => 'set_currentmove',
        reader  => 'get_currentmove',
);

has CustomDrawCode => (
    isa     => 'CodeRef',
    is      => 'rw',
    default => sub { sub{}  },
    lazy    => 1,
);

has KeyboardCallback => (
    isa     => 'CodeRef',
    is      => 'rw',
    default => sub { sub{  }  },
);

has glWindow => (
    isa     => 'Any',
    is      => 'rw',
    default => undef,
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
    default => 1024
);

has height  => (
    isa => 'Int',
    is  =>'rw',
    default=> 900
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

#sub Reshape {
    #glMatrixMode(GL_PROJECTION);
    #glPushMatrix();
    #glLoadIdentity();

    ## first parameter is eye position
    ## second is center position
    ## third is the direction the camera is looking at

    #gluPerspective(1000.0, 1.0 , 1.0, 30.0); 
    #glMatrixMode(GL_MODELVIEW);
    #glPushMatrix();


    ## I think gluLookAt doesn't work at all here and there's supposed to be only one projection, and that should be
    ## GL_MODELVIEW , but it doesn't really work ...
    #gluLookAt(120,120,100,
              #0  ,  0,  0,
              #-1 , -1, -1,
          #);
    #glLoadIdentity();
#}

sub InitGL {              

    # Shift the width and height off of @_, in that order
    my ($self,$width, $height) = @_;

    # Set the background "clearing color" to black
    glClearColor(0.0, 0.0, 0.0, 0.0);

    # Enables clearing of the Depth buffer 
    glClearDepth(1.0);                    

    # The type of depth test to do
    glDepthFunc(GL_LESS);         

    # Enables depth testing with that type
    glEnable(GL_DEPTH_TEST);              
    
    # Enables smooth color shading
    glShadeModel(GL_SMOOTH);      

    # Reset the projection matrix
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity;

    # Calculate the aspect ratio of the Window
    gluPerspective(45.0, $width/$height, 0.1, 100.0);

    # Reset the modelview matrix
    glMatrixMode(GL_MODELVIEW);


}

sub ReSizeGLScene {

}






sub Init {
    my ($self) = @_;
# --- Main program ---

# Initialize GLUT state
    glutInit;  

# Select type of Display mode:   
# Double buffer 
# RGB color (Also try GLUT_RGBA)
# Alpha components removed (try GLUT_ALPHA) 
# Depth buffer */  
    glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);  

# Get a 640 x 480 window
    glutInitWindowSize($self->width, $self->height);  

# The window starts at the upper left corner of the screen
    glutInitWindowPosition(0, 0);  

# Open the window  
    $self->glWindow(glutCreateWindow("[Perl] Rubik's cube"));

# Register the function to do all our OpenGL drawing.

    my $draw_frame_subref = sub { $self->DrawFrame(@_) };

    glutDisplayFunc($draw_frame_subref);  

# Go fullscreen.  This is as soon as possible. 
    #glutFullScreen;

# Even if there are no events, redraw our gl scene.
    glutIdleFunc($draw_frame_subref);

# Register the function called when our window is resized. 
    glutReshapeFunc(\&ReSizeGLScene);

# Register the function called when the keyboard is pressed.
    #glutKeyboardFunc(\&KeyboardCallback);
    glutKeyboardFunc(sub { $self->KeyboardCallback->(@_); } );

# Initialize our window.
    $self->InitGL($self->width, $self->height);


    glutMainLoop;  
}



sub DrawFrame {
    my ($self,$sub) = @_;# sub is the sub called for drawing the frame
    # Clear the screen and the depth buffer
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);  
    glLoadIdentity;


    #say "rendered!";
    glTranslatef(1, -2.0, -20.0); 
    glRotatef(50,0,0,0);
    glRotatef(-45,0,1,0);

    $self->CustomDrawCode->();

    $self->rotate_face;

    glutSwapBuffers;
}


sub rotate_face {
    my($self) = @_;

    my $face = $self->currentmove;

    return unless $face;

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
                #say $self->model;
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
