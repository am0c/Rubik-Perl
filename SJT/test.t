use strict;
use warnings;
use Test::More;
my $out=`./SJT`;

my $stop_at_first_failed = !$ARGV[0]; # if any first argument is used

my @lines = split /\n/,$out;

my $i = 0;

my @tests = qw/
<1,<2,<3,<4,
<1,<2,<4,<3,
<1,<4,<2,<3,
<4,<1,<2,<3,
>4,<1,<3,<2,
<1,>4,<3,<2,
<1,<3,>4,<2,
<1,<3,<2,>4,
<3,<1,<2,<4,
<3,<1,<4,<2,
<3,<4,<1,<2,
<4,<3,<1,<2,
>4,>3,<2,<1,
>3,>4,<2,<1,
>3,<2,>4,<1,
>3,<2,<1,>4,
<2,>3,<1,<4,
<2,>3,<4,<1,
<2,<4,>3,<1,
<4,<2,>3,<1,
>4,<2,<1,>3,
<2,>4,<1,>3,
<2,<1,>4,>3,
<2,<1,>3,>4,
/;


while(1) {
	last unless defined($lines[$i]);
	my $good = ok(	
		$lines[$i] eq $tests[$i] , 
		"expected $tests[$i] , got $lines[$i]"
	);
	last if ($stop_at_first_failed && !$good) ||
		++$i==@tests;
}

if($i<@tests-1) {
	warn "Wanted to run more tests but didn't get enough output from program!";
}

done_testing();
