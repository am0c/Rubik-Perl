use GD::SVG;
use List::AllUtils qw/max/;
use feature ':5.10';
use Carp;




sub draw {
    my @perm = @{$_[0]};
    my $file = $_[1];

    my $circ_rad = 2;# circle radius for joints
    my $img   = GD::SVG::Image->new(500,500);
    $img->setThickness(4);
    my $d = 10;#distance between
    my $l = @perm; #height units of the image
    my $length = $d;# step length



=head1 DESCRIPTION

Permutations can be viewed as braids but braids are much more general.
(if you consider a permutation and apply it to itself it returns to the identical permutation, if you
have a braid that's a transposition and apply it to itself you get a double-twist, one more time you get
a triple twist and so forth this continues indefinitely).

=cut

my ($DOWN,$RIGHT,$LEFT)=
(    0,    +1,   -1);

# visual representation of a permutaion in the form of a braid
# http://en.wikipedia.org/wiki/Braid_theory

# taken from tables_gfx branch

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
        map { int($_) } 
        $map[$v/255]->( ($v % 255) / 256 );

        #print join(',',@a)."\n";

        return $img->colorAllocate(@a);
    };
############### cut here


my @colours = map { ramp($_,1,~~@perm+2) } (1..@perm);
#print join(' ',@colours);exit;

# height of the image is determined by the transposition of the farthest apart elements( which is actually ~~@perm but ...)
#my $l = max(map { abs($_-$perm($_)+1); } (1..@perm)); 




#
#  Graphical primitives:
#  draw a segment of a line directly down/left/right one unit.
#


    my ($lastx,$lasty) = (0,0); # last (x,y) position since the last step
    # it's the colour currently used for painting;
    my ($linestart,$lastdir,$colour);


    sub step {
        my ($dir) = @_;
        #print "dir=$dir\n";

        confess "x=$x" if $x<0;
        confess "y=$x" if $y<0;


        $img->ellipse($lastx,$lasty,$circ_rad,$circ_rad,$colour)
        if(
            $lastdir != -3 &&
            !$linestart &&
            $dir != $lastdir
        );


        given ($dir) {
            when($DOWN) { $img->line($lastx,$lasty,$lastx    ,$lasty+$length,$colour);$lasty+=$length;            } # DOWN
            when($LEFT) { $img->line($lastx,$lasty,$lastx-$d ,$lasty+$length,$colour);$lasty+=$length;$lastx-=$d; } # LEFT
            when($RIGHT) { $img->line($lastx,$lasty,$lastx+$d ,$lasty+$length,$colour);$lasty+=$length;$lastx+=$d; } # RIGHT
        };
        $lastdir = $dir;
        $linestart = 0;
    }


    for my $i (1..@perm-1) {
        #print "i=$i\n";
        $colour = $colours[$i];
        $linestart = 1;
        $lastdir = -3;

        $lastx = $i * $d; # this is the x position where the current strand starts
        $lasty = 0;

        step(0);
        step(-($i<=>$perm[$i])) for 1..(abs($i-$perm[$i]));
        step(0) for 1..($l - abs($i-$perm[$i]));
        step(0);
    };

    open my $fh,">$file";
    print $fh $img->svg;

};



draw([0,6,1,2,4,5],'/tmp/stuff.svg');


