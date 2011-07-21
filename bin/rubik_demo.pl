#!/usr/bin/perl -I./lib
# Thu 18 Feb 2010 06:14:49 PM EST
# Stefan Petrea 
#
# simulation of Rubik's cube using OpenGL
#
use Carp;
use Rubik::View;
use Rubik::Model;
use SDL::Event;
use SDL::Events;
use Time::HiRes qw(usleep);


my $view = Rubik::View->new();
my $model= Rubik::Model->new({view=>$view});

# all of the turns are 90 degrees
my @faces = qw/Fi U D/; # cyclic moves list
my $turnspeed = 2;
my $turnangle = 90;
my $iface=0; # face iterator

confess "turn speed must be an integer"            if(  $turnspeed != int($turnspeed));
confess "turn speed must divide $turnangle"    unless(  $turnangle % $turnspeed == 0);

$view->currentmove( $faces[$iface] ); # start with this face


print "ORDER:".($model->rubik->F * $model->rubik->R)->order."\n"; # order is 105

my $iter=0;



#$model->scramble; # make a random series of moves to scramble the cube
#       - add tests

$|=1;


$view->CustomDrawCode(
    sub {
        usleep(2000);
        #glRotatef(2,0,1,0); # rotate it while the moves are carried out
        $view->spin( $view->spin + $turnspeed );#need to take in account something where divisibility is not needed
        if(  $view->spin % $turnangle == 0) {
            $view->spin(0);
            $model->move($faces[$iface]);
            $iface = ($iface + 1) % @faces;
            $view->currentmove($faces[$iface]);
            print "Doing move $faces[$iface]\n";
        };
    }
);


$view->KeyboardCallback(
    sub {
        my ($self) = @_;
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
            glutReshapeWindow(640, 480);
        }

        # If escape is pressed, kill everything.
        if ($key == ESCAPE) 
        { 
            # Shut down our window 
            glutDestroyWindow($self->glWindow); 

            # Exit the program...normal termination.
            exit(0);                   
        };
    }
);




$view->Init;
