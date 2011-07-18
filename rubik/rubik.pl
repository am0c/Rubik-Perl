#!/usr/local/bin/perl

# Thu 18 Feb 2010 06:14:49 PM EST
# Stefan Petrea 
#
# simulation of Rubik's cube using OpenGL
#

package main;
use Carp;
use Rubik::View;
use Rubik::Model;
use SDL::Event;
use SDL::Events;
use Time::HiRes qw(usleep);


use SDL;
#use SDL::App;

my $view = Rubik::View->new();
my $model= Rubik::Model->new({view=>$view});

# the following attributes exist
# $view->model
# $model->view
# they're needed for interoperability between the objects


sub for_test {
    # first parameter will be the smallest number on that face and the corners
    # will be depicted in different colours for debugging purposes
    my ($n) = @_;
    $model->setColor($n+6,[1,.5,1]);
    $model->setColor($n+8,[0,0,1]);
    $model->setColor($n+2,[0,1,1]);
    $model->setColor($n+0,[1,1,1]);
}


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
















$view->Init;
