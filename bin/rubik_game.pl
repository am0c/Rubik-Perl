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


my $view = Rubik::View->new();
my $model= Rubik::Model->new({view=>$view});



my $turnspeed = 2;
my $turnangle = 90;

confess "turn speed must be an integer"            if(  $turnspeed != int($turnspeed));
confess "turn speed must divide $turnangle"    unless(  $turnangle % $turnspeed == 0);


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
                $move_current = $move_buffer[0];
                $move_lock  = 1;
            };
        };

        if($move_lock) {
            $view->spin( $view->spin + $turnspeed );#need to take in account something where divisibility is not needed
        };

        if(  $view->spin == $turnangle ) {
            #end move

            shift @move_buffer; 
            if(@move_buffer) {
                $move_current = $move_buffer[0];
            };

            print "current move=$move_current";
            $view->spin(0);


            $model->move(        $move_current );
            $view->currentmove(  $move_current );

            $move_current = undef;
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


        my @allowed_moves = map { ord $_ } split //,"furbld";

        print Dumper \@allowed_moves;
        print Dumper \$key;

        if( any { $key == $_ } @allowed_moves ) {
            print "$key\n";
            push @move_buffer, uc(chr($key));
        };
    }
);


$view->Init;
