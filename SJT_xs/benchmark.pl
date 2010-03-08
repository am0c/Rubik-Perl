use strict;
use warnings;
use Benchmark qw/cmpthese timethese/;
use Algorithm::Permute;
use SJT;

my $n = 10; # objects to permute
my $iter=5;
my $p = new Algorithm::Permute([1..$n], $n);

sub nextPermute(\@)
{
	my( $vals )= @_;
	my $last= $#{$vals};
	return ""   if  $last < 1;
	# Find last item not in reverse-sorted order:
	my $i= $last-1;
	$i--   until  $i < 0  ||  $vals->[$i] lt $vals->[$i+1];
	# If complete reverse sort, we are done!
	return ""   if  -1 == $i;
	# Re-sort the reversely-sorted tail of the list:
	@{$vals}[$i+1..$last]= reverse @{$vals}[$i+1..$last]
	if  $vals->[$i+1] gt $vals->[$last];
	# Find next item that will make us "greater":
	my $j= $i+1;
	$j++  until  $vals->[$i] lt $vals->[$j];
	# Swap:
	@{$vals}[$i,$j]= @{$vals}[$j,$i];
	return 1;
}

sub make_orderings
{
	my $num = shift;

	my @arr = (1 .. $num);

	return sub {
		my $last = $#arr;

		my $i = $last - 1;
		$i-- while 0 <= $i && $arr[$i] >= $arr[$i+1];
		return if $i == -1;

		@arr[$i+1..$last] = reverse @arr[$i+1..$last]
		if $arr[$i+1] > $arr[$last];

		my $j=$i+1;
		$j++ while $arr[$i] >= $arr[$j];

		@arr[$i,$j] = @arr[$j,$i];

		return @arr;
	}
}


cmpthese(
	$iter,
	{
		'A::P' => sub {

			while (my @res = $p->next) {
				#print join(", ", @res), "\n";
			}

		},
		'SJT_XS'=> sub {

			my $s = SJT->new($n);
			while($s->next_perm()){
				my @p = @{$s->{permutation}};
			};

		},
		'tye' => sub {

			my @w= (1..$n);
			do {
			} while( nextPermute(@w) );

		},
		'dchld' => sub {
			my $i = make_orderings($n);
			while(my @a = $i->()){
			};
		},
		'SJT_asm' => sub {
			`./../SJT/SJT_for_benchmark`;
		},
		'C++_STL' => sub {
			`./../SJT/perm_cpp_stl`;
		},
	}
);
