use Test::More;
my $out=`./SJT`;

my @lines = split /\n/,$out;

my $i = 0;

my @tests = qw/
1,2,3,4,
1,2,4,3,
1,4,2,3,
4,1,2,3,
4,1,3,2,
1,4,3,2,
1,3,4,2,
1,3,2,4,
3,1,2,4,
3,1,4,2,
3,4,1,2,
4,3,1,2,
4,3,2,1,
3,4,2,1,
3,2,4,1,
3,2,1,4,
2,3,1,4,
2,3,4,1,
2,4,3,1,
4,2,3,1,
4,2,1,3,
2,4,1,3,
2,1,4,3,
2,1,3,4,
/;


while(1) {
	last unless ok(	
		$lines[$i] eq $tests[$i] , 
		"expected $tests[$i] , got $lines[$i]"
	);
	$i++;
	last if $i==24;
}

done_testing();