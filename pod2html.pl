#!/usr/local/bin/perl
#!/usr/bin/perl

#switch between the first two lines depending on what system I am
use strict;
use Pod::Simple::HTML;

my $parser = Pod::Simple::HTML->new();

if (defined $ARGV[0]) {
    open IN, $ARGV[0]  or die "Couldn't open $ARGV[0]: $!\n";
} else {
    *IN = *STDIN;
}

if (defined $ARGV[1]) {
    open OUT, ">$ARGV[1]" or die "Couldn't open $ARGV[1]: $!\n";
} else {
    *OUT = *STDOUT;
}

$parser->index(1);
$parser->html_css('http://search.cpan.org/s/style.css');

$parser->output_fh(*OUT);
$parser->parse_file(*IN);

