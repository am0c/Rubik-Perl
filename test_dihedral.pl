use CM::Group::Dihedral;
my $g = CM::Group::Dihedral->new({n=>10});
$g->compute;
$g->rearrange;
print "$g";
