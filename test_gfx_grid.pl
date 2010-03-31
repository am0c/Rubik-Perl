#!/usr/bin/perl
use strict;
use warnings;
use GD;
use List::AllUtils qw/reduce/;
use Data::Dumper;


#
#
# Wed 31 Mar 2010 05:46:05 AM EEST
# github.com/wsdookadr
#
# code modified (originally from pm http://www.perlmonks.org/index.pl?node_id=831157 )
#

# the code ramp is supposed to make a correspondence between a range of numbers and colours in RGB
#
#
# this one has some problems(it produces some of the colours too similar to each other, they are hard to distinguish)

my @map=(
	sub{(         0,             0,   $_[0] * 255 )},
	sub{(         0,     $_[0]*255,           255 )},
	sub{(         0,           255, (1-$_[0])*255 )},
	sub{( $_[0]*255,           255,             0 )},
	sub{(       255, (1-$_[0])*255,             0 )},
	sub{(       255,             0,     $_[0]*255 )},
	sub{(       255,     $_[0]*255,           255 )},
);

sub ramp {
	my( $v, $vmin, $vmax ) = @_;

	## Peg $v to $vmax if it is greater than $vmax
	$v = $vmax if $v > $vmax;
	## Or peg $v to $vmin if it is less tahn $vmin.
	$v = $vmin if $v < $vmin;
	## Normalise $v relative to $vmax - $vmin
	$v = 
	( $v    - $vmin ) /
	( $vmax - $vmin ) ;
	## Scale it to the range 0 .. 1784
	$v *= 1785;

	my @a = 
	map { int } 
	$map[$v/255]->( ($v % 255) / 256 );

	#print join(',',@a)."\n";

	return 
	($a[2]<<8 ) |
	($a[1]<<4 ) |
	($a[0]    ) ;
};


# just for testing purposes
my $a = 
[
	[1,2,3] ,
	[4,5,6] ,
	[7,8,9]
];

my $x_size = 400;
my $y_size = 400;

my $img = GD::Image->new($x_size, $y_size, 1);

for my $x (0..$x_size-1) {
    for my $y (0..$y_size-1) {

        # some sample values in the range 0-1
        #my $idx = $a->[ ($x / $x_size) * 3 ]->[ ($y / $y_size) * 3];

        $img->setPixel($x, $y, ramp($a->[ ($x / $x_size) * 3 ]->[ ($y / $y_size) * 3] ,  1,16 )) ;
    }
};




open IMG, ">", "sample-image.png" or die $!;
binmode IMG;
print IMG $img->png();
close IMG;
