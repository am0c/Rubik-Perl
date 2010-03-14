use CM::Morphism;
use CM::Group::Sym;
use Test::More;
use strict;
use warnings;

my $G = CM::Group::Sym->new({n=>4});
$G->compute_elements()->();

my $f = CM::Morphism->new({
		f        => sub {
			my ($x) = @_;
			return $x;
		},
		domain   => $G,
		codomain => $G,
});

my $kerf = $f->kernel;

my $Gdiv_kerf = $G->factor($kerf);

printf "%s\n",@{$kerf->elements};

# goal is to say    $G->factor($f->kernel) =~  $f->image

done_testing;
