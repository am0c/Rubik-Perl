use CM::Group::Sym;
use CM::Group::Dihedral;
use CM::Permutation;
use CM::Permutation::Cycle;
use lib './lib/';
sub p{
    CM::Permutation->new(@_);
}
my $g = CM::Group::Sym->new({n=>4});
$g->compute;

#$g->cayley_digraph('/tmp/bla.gif',
#    [p(2,1,3,4),p(1,3,2,4),p(1,2,4,3)]);



#$g->cayley_digraph('bla.gif',
    #[p(2,1,3,4),p(1,3,2,4),p(1,2,4,3)]);


my $d = CM::Group::Dihedral->new({n=>10});
$d->compute;

$d->cayley_digraph('bla2.gif',
    [$d->Rgen,$d->Sgen]);


#my $g = CM::Group::Sym->new({n=>5});
#$g->compute;
#$g->cayley_digraph('/tmp/bla2.gif',
    #[p(2,1,5,3,4),p(1,3,2,4,5),p(1,2,4,3,5)]);
