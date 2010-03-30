#!/usr/bin/perl
use strict;
use warnings;
use GD;

my @colorramp = ( # darkblue to yellow
    # R G B
    0x000000,
    0x000020,
    0x000040,
    0x000060,
    0x000080,
    0x0000a0,
    0x2000c0,
    0x4000e0,
    0x6000f0,
    0x8000d0,
    0xa00080,
    0xc00040,
    0xd04000,
    0xe08000,
    0xffc000,
    0xffff00,
);


my $a = [
[4  , 8  , 3]  ,
[15 , 14 , 10] ,
[7  , 8  , 14]
];

my $x_size = 400;
my $y_size = 400;

my $img = GD::Image->new($x_size, $y_size, 1);

for my $x (0..$x_size-1) {
    for my $y (0..$y_size-1) {

        # some sample values in the range 0-1
        my $idx = $a->[ ($x / $x_size) * 3 ]->[ ($y / $y_size) * 3];

        $img->setPixel($x, $y, $colorramp[$idx]);
    }
}

open IMG, ">", "sample-image.png" or die $!;
binmode IMG;
print IMG $img->png();
close IMG;
