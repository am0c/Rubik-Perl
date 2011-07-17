#!/usr/bin/perl
use strict;
use warnings;
use OpenGL;
use Time::HiRes qw(usleep);
use SDL::Event;
use SDL::Events;
use Data::Dumper;


my ($width,$height)=
(1024,900);

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

sub Draw{
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
};



sub Init_rewrite {
    glpOpenWindow(width => $width, height => $height,attributes => [GLX_RGBA,GLX_DOUBLEBUFFER]);
    glClearColor(0,0,0,1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glShadeModel (GL_FLAT);



    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();

# first parameter is eye position
# second is center position
# third is the direction the camera is looking at

    gluPerspective(1000.0, 1.0 , 1.0, 100.0); 
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();


# I think gluLookAt doesn't work at all here and there's supposed to be only one projection, and that should be
# GL_MODELVIEW , but it doesn't really work ...
    gluLookAt(
        100,100,100,
        0  ,  0,  0,
        +1 , +1, +1,
    );
    glLoadIdentity();



    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();

    glDisable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_LIGHT1);
    glEnable(GL_NORMALIZE);
    glLoadIdentity();

    glTranslatef (0,0,0);
 
}



sub Init {
    glpOpenWindow(width => $width, height => $height,attributes => [GLX_RGBA,GLX_DOUBLEBUFFER]);
    glClearColor(0,0,0,1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glShadeModel (GL_FLAT);



    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();

# first parameter is eye position
# second is center position
# third is the direction the camera is looking at

    gluPerspective(1000.0, 1.0 , 1.0, 100.0); 
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();


# I think gluLookAt doesn't work at all here and there's supposed to be only one projection, and that should be
# GL_MODELVIEW , but it doesn't really work ...
    gluLookAt(
        100,100,100,
        0  ,  0,  0,
        -1 , -1, -1,
    );
    glLoadIdentity();



    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();

    #glDisable(GL_CULL_FACE);
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_LIGHT1);
    glEnable(GL_NORMALIZE);
    #glLoadIdentity();

    #glTranslatef (1,0,0);
    glRotatef(20,0,1,0);
}



sub DrawFrame {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glPushMatrix();
    #$sub->($self->currentmove);

    Draw();

    glPopMatrix();
    glFlush();
    glXSwapBuffers;
};


Init;

my $event = SDL::Event->new;
my $i = 0;
while (1){

    usleep 300;
    #$pos->[0]++ if $i % 30 == 0;
    #$i++;


	while(SDL::Events::poll_event($event)) {
		print "Aaaaaaaaaaaa";
		#if ( $type == SDL_KEYUP ) {
			#print "Aaaaaaaaa";
		#};
	};
    DrawFrame();
	SDL::Events::pump_events();
};
