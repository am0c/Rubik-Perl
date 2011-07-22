#!/usr/bin/perl -I./lib
#
# rubik's cube game
#
use Data::Dumper;
use Carp;
use Rubik::View;
use Rubik::Model;
use SDL::Event;
use SDL::Events;
use Time::HiRes qw(usleep);
use List::AllUtils qw/any/;
use feature ':5.10';


my $view = Rubik::View->new();
my $model= Rubik::Model->new({view=>$view});



my $turnspeed = 3;
my $turnangle = 90;

confess "turn speed must be an integer"            if(  $turnspeed != int($turnspeed));
confess "turn speed must divide $turnangle"    unless(  $turnangle % $turnspeed == 0);


$|=1;


my @move_buffer;
my $move_lock = 0;
my $move_current = 0;


$view->CustomDrawCode(
    sub {
        usleep(2000);

        if($view->spin == 0) {
            if(@move_buffer > 0) {
                $move_lock = 1;
                my $new_move = shift @move_buffer;
                $view->currentmove($new_move);
                #taking view out of the state $view->spin==0, on next execution of this sub it will
                #go on the else{} branch
                $view->spin( $view->spin + $turnspeed );
            };
        } elsif($view->spin == $turnangle) {
            #$model->move permutes the visible faces of the cubies w.r.t. the new configuration
            #after the rotation
            $model->move($view->currentmove);
            $view->spin(0);
            $move_lock = 0;
        } else {
            if($move_lock){
                say "increase spin!";
                say "spin=".$view->spin;
                $view->spin( $view->spin + $turnspeed );
            };
        };

    }
);

$view->KeyboardCallback(
    sub {
        my ($self) = @_;
        # Shift the unsigned char key, and the x,y placement off @_, in
        # that order.
        my ($key, $x, $y) = @_;


        my @allowed_moves = map { ord $_ } split //,"furbld";

        #print Dumper \@allowed_moves;
        #print Dumper \$key;

        if( any { $key == $_ } @allowed_moves ) {
            #print "$key\n";
            push @move_buffer, uc(chr($key));
        };
    }
);


$view->Init;
