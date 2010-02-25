use strict;
use warnings;
use CM::Group::Sym;
use CM::Group::Dihedral;
use CM::Group::ModuleMultiplicationGroup;

# TODO: figgure out a way to handle S_5 which has 120 elements(will some of the colours be easily confused,
# if there's a way to visualize S_5 and still distinguish the elements)


# Acme::AsciiArt2HtmlTable doesn't install properly on Windows , it fails a test, but force install works ok:
# dmake
# dmake test
# dmake install


#CM::Group::Sym->new({n=>4})->draw_asciitable("table.html");



#my $d = CM::Group::Dihedral->new({n=>10});
#$d->compute;
#$d->draw_asciitable("table2.html");



# BUG:
# still table not symmetric for some reason ...
# rows are swapped somehwere ...


my $d1 = CM::Group::ModuleMultiplicationGroup->new({n=>5});
#$d1->rearrange();
$d1->compute();

print $d1->elements->[3]."\n";
$d1->draw_asciitable("table3.html");



