use strict;
use warnings;
use Benchmark qw/timethese/;
use Algorithm::Permute;
use SJT;



my $n = 8; # objects to permute

timethese(
	20,
	{
		'Algorithm::Permute' => sub {
			use Algorithm::Permute;
			my $p = new Algorithm::Permute([1..$n], $n);
			while (my @res = $p->next) {
				#print join(", ", @res), "\n";
			}
		},
		'SJT'                => sub {
			my $s = SJT->new($n);
			while($s->next_perm()){
				my @p = @{$s->{permutation}};
				#$s->print_perm;
			};
		},
	}
);
