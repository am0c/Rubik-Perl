package SJT;

use 5.010000;
use strict;
use warnings;
use Carp;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('SJT', $VERSION);

sub new {
	my ($class,$n) = @_;
	# should use Params::Validate
	confess "expected number" unless $n =~ /^\d+$/;
	return bless {
		permutation 	=> [0..$n     ] ,
		direction 	=> [0,(-1)x$n ] ,
	},$class;
}


# Preloaded methods go here.

1;
__END__

=head1 NAME

SJT - Perl XS implementation of Steinhaus Johnson Trotter algorithm

=head1 SYNOPSIS

  use SJT;
  blah blah blah

=head1 DESCRIPTION


=head1 SEE ALSO

=head1 AUTHOR

Stefan Petrea, C<< <stefan.petrea at gmail.com> >>


=cut
