#! /usr/bin/perl -w

use OpenGL qw(:all);    # Use the OpenGL module
use strict;             # Use strict typechecking

# ASCII constant for the escape key
use constant ESCAPE => 27;
use Time::HiRes qw(usleep);
use feature ':5.10';

# Global variable for our window
my $window;

my $pos = [0,0,0];
my $colours = 
        [
            [1 , 0 , 0] , #Right
            [1 , 0 , 1] , #Down
            [0 , 0 , 1] , #Left
            [1 , 1 , 0] , #Up
            [0 , 1 , 0] , #Front
            [0 , 1 , 1] , #Back
        ];
my $faces = 
        [
            [0, 1, 2, 3,], 
            [3, 2, 6, 7,], 
            [7, 6, 5, 4,], 
            [4, 5, 1, 0,],
            [5, 6, 2, 1,], 
            [7, 4, 0, 3,], 
        ];


my @v = (
    [    -1 +$pos->[0], -1 +$pos->[1], -1 +$pos->[2],], 
    [    -1 +$pos->[0], -1 +$pos->[1], 1  +$pos->[2],],
    [    -1 +$pos->[0], 1  +$pos->[1], 1  +$pos->[2],],
    [    -1 +$pos->[0], 1  +$pos->[1], -1 +$pos->[2],],
    [    1  +$pos->[0], -1 +$pos->[1], -1 +$pos->[2],],
    [    1  +$pos->[0], -1 +$pos->[1], 1  +$pos->[2],],
    [    1  +$pos->[0], 1  +$pos->[1], 1  +$pos->[2],],
    [    1  +$pos->[0], 1  +$pos->[1], -1 +$pos->[2],]
);

# Rotation variables for triangle and quad
my $rtri  = 0.0;
my $rquad = 0.0;
my $width = 640;
my $height= 480;

sub DrawCube {
    glBegin(GL_QUADS);
    for(my $i=0;$i<6;$i++){
        # the 6 facelets of a cubie are coloured based on the property
        glColor3f(@{$colours->[$i]});


        for(my $j=0;$j<4;$j++){
            my $k=$faces->[$i]->[$j];
            #print Dumper $v[$k];
            glVertex3f(@{$v[$k]});
        }

    }
    glEnd();
}


# A general GL initialization function 
# Called right after our OpenGL window is created
# Sets all of the initial parameters
sub InitGL {              

    # Shift the width and height off of @_, in that order
    my ($width, $height) = @_;

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


# The function called when our window is resized 
# This shouldn't happen, because we're fullscreen
sub ReSizeGLScene {

    # Shift width and height off of @_, in that order
    my ($width, $height) = @_;

    # Prevent divide by zero error if window is too small
    if ($height == 0) { $height = 1; }

    # Reset the current viewport and perspective transformation
    glViewport(0, 0, $width, $height);              

    # Re-initialize the window (same lines from InitGL)
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity;
    gluPerspective(45.0, $width/$height, 0.1, 100.0);
    glMatrixMode(GL_MODELVIEW);
}

# The main drawing function.
sub DrawGLScene {
    usleep(50_000);
    # Clear the screen and the depth buffer
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);  

    # Reset the view
    glLoadIdentity;

    # Move to the left 1.5 units and into the screen 6.0 units
    glTranslatef(-1.5, -3.0, -16.0); 

    #say $rquad;
    #glRotatef($rquad,0,1,,0);
    #$rtri  = $rtri  + 15.0; 
    #$rquad = $rquad + 4.0; 


    DrawCube;
    glutSwapBuffers;
}

# The function called whenever a key is pressed. 
sub keyPressed {

    # Shift the unsigned char key, and the x,y placement off @_, in
    # that order.
    my ($key, $x, $y) = @_;
    
    # Avoid thrashing this procedure
    # Note standard Perl does not support usleep
    # For finer resolution sleep than seconds, try:
    #    'select undef, undef, undef, 0.1;'
    # to sleep for (at least) 0.1 seconds
    sleep(100);

    # If f key pressed, undo fullscreen and resize to 640x480
    if ($key == ord('f')) {

        # Use reshape window, which undoes fullscreen
        glutReshapeWindow($width, $height);
    }

    # If escape is pressed, kill everything.
    if ($key == ESCAPE) 
    { 
        print "Exited";
        # Shut down our window 
        glutDestroyWindow($window); 
        
        # Exit the program...normal termination.
        exit(0);                   
    }
}


sub Init {

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
glutInitWindowSize($width, $height);  

# The window starts at the upper left corner of the screen
glutInitWindowPosition(0, 0);  

# Open the window  
$window = glutCreateWindow("Jeff Molofee's GL Code Tutorial ... NeHe '99");  

# Register the function to do all our OpenGL drawing.
glutDisplayFunc(\&DrawGLScene);  

# Go fullscreen.  This is as soon as possible. 
glutFullScreen;

# Even if there are no events, redraw our gl scene.
glutIdleFunc(\&DrawGLScene);

# Register the function called when our window is resized. 
glutReshapeFunc(\&ReSizeGLScene);

# Register the function called when the keyboard is pressed.
glutKeyboardFunc(\&keyPressed);

# Initialize our window.
InitGL($width, $height);
  
# Start Event Processing Engine

};


Init;
glutMainLoop;  

