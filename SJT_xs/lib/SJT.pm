package SJT;
use 5.010000;
use strict;
use warnings;
use Carp;
use List::AllUtils qw/zip/;
use lib '../lib';
use CM::Permutation;

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
		n		=> $n,
		permutation 	=> [0..$n     ] ,
		direction 	=> [0,(-1)x$n  ] ,
		perm_idx	=> 0,
	},$class;
}






sub next_perm_obj {
	my ($self) = @_;
	if($self->{perm_idx}++) {
		return	$self->next_perm
			? CM::Permutation->new( @{$self->{permutation}}[1..$self->{n}])
			: undef;
	}else {
		return CM::Permutation->new(1..$self->{n});
	};
	return undef;
}

sub print_perm {
	my ($self) = @_;
	my @a = @{$self->{permutation}};
	my @b = map { $_ < 0 ?'<':'>' } @{$self->{direction}};

	print join(' ',zip @b,@a);
	print "\n";
}


# Preloaded methods go here.

1;
__END__

=head1 NAME

SJT - Perl XS implementation of Steinhaus Johnson Trotter algorithm

=head1 SYNOPSIS

	use SJT;

	my $s = SJT->new(3);
	while($s->next_perm()){
		#@{$s->{permutation}};
		$s->print_perm;
	};

	1 2 3
	1 3 2
	3 1 2
	3 2 1
	2 3 1
	2 1 3

=head1 DESCRIPTION

SJT is pretty fast because it requires just one transposition to get to the next permutation.

=head1 SEE ALSO

=head1 AUTHOR

Stefan Petrea, C<< <stefan.petrea at gmail.com> >>


=cut
