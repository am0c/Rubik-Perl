use GD::SVG;

# visual representation of a permutaion in the form of a braid
# http://en.wikipedia.org/wiki/Braid_theory


my $img   = GD::SVG::Image->new(500,500);
$img->setThickness(3);
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


my @perm = (5,3,1,4,2,6,8,7);
my @colours = map { ramp($_,1,~~@perm+2) } (1..@perm+1);
#print join(' ',@colours);exit;



$img->line($_*10,0,($_*10)+200,200,$colours[$_]) for 1..@perm;





open my $fh,">/tmp/stuff.svg";
print $fh $img->svg;



