package mathscript;
use lib './lib';
use strict;
use warnings;
use CM::Permutation;
use CM::Permutation::Cycle;
use CM::Group::Sym;
use CM::Group::Dihedral;
use CM::Group::Altern;
use CM::Group::ModuloAddition;
use CM::Group::ModuloMultiplication;
use CM::Group::Product;
use CM::Polynomial::Chebyshev;
use CM::Polynomial::Cyclotomic;
use Moose;
use Devel::REPL;
use namespace::clean -except => [ qw(meta) ];

has '_repl' => (
  is => 'ro', isa => 'Devel::REPL', required => 1,
  default => sub { 
      
      my $r = Devel::REPL->new();
      $r->load_plugin($_) for qw(History LexEnv MultiLine::PPI);
      # TODO: find a way for completion to work with Devel::REPL, tried the listed plugins, and they didn't work
      $r->eval('


          sub perm {
          return CM::Permutation->new(@_);
          };

          sub cycle {
          return CM::Permutation::Cycle->new(@_);
          };

          sub poly_cyclotomic {
          return CM::Polynomial::Cyclotomic->new(@_);
          };


          sub poly_chebyshev {
          return CM::Polynomial::Cyclotomic->new(@_);
          };

          ');
      $r;
  }
  
);
sub run {
    my ($self) = @_;
    $self->_repl->run;
}

sub import {
  my ($class, @opts) = @_;
  $class->new->run;
}

1;
