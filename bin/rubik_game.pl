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
use List::AllUtils qw/any/;


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


my @move_buffer  ;
my $move_lock = 0;
my $move_current = 0;


$view->CustomDrawCode(
    sub {
        return unless @move_buffer;

        usleep(2000);


        #TODO: bug for this draw code getting keys from buffer
        if( $view->spin == 0 ) {

            if(!$move_lock) {
                $move_current = shift @move_buffer;
            };
            $move_lock  = 1;
            #start move
        };

        $view->spin( $view->spin + $turnspeed );#need to take in account something where divisibility is not needed

        if(  $view->spin == $turnangle ) {
            #end move

            print "current move=$move_current";
            $view->spin(0);
            $model->move(      $move_current);
            $view->currentmove($move_current);
            #print "Doing move $faces[$iface]\n";

            $move_lock = 0;
        };

    }
);

$view->KeyboardCallback(
    sub {
        my ($self) = @_;
        # Shift the unsigned char key, and the x,y placement off @_, in
        # that order.
        my ($key, $x, $y) = @_;


        my @allowed_moves = map { ord $_ } qw/F U R B L D/;

        if( any { $key == $_ } @allowed_moves ) {
            print "$key\n";
            push @move_buffer,uc(chr($key));
        };

        #if ($key == ord('f')) {

            ## Use reshape window, which undoes fullscreen
            #glutReshapeWindow(640, 480);
        #}

        if ($key == ESCAPE) 
        { 
            # Shut down our window 
            glutDestroyWindow($self->glWindow); 
            exit(0);                   
        };
    }
);


$view->Init;
