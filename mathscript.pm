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
      # TODO: find a way for completion to work with Devel::REPL, tried the listed plugins, and they didn't work
      $r->load_plugin($_) for qw(History LexEnv MultiLine::PPI CompletionDriver::Keywords CompletionDriver::Methods);
      $r->eval('

          sub help {
          "

                  mathshell is a shell for the modules in the CM::Permutation distribution

                  permutations:
                  ------------

                  cycle  - permutation cycle
                  perm   - permutation

                  polynomials:
                  -----------

                  pcyclo - nth cyclotomic polynomial
                  pcheby - nth chebyshev polynomial

                  groups:
                  ------

                  gsym   - S_n
                  galt   - A_n
                  gdih   - D_2n
                  gadd   - (Z_n,+)
                  gmul   - (Z_n,*)
                  gx     - group product

                  Ex:  gsym({n=>3})->compute()

          ";
          }


          sub perm {
          return CM::Permutation->new(@_);
          };

          sub cycle {
          return CM::Permutation::Cycle->new(@_);
          };

          sub pcyclo {
          return CM::Polynomial::Cyclotomic->new(@_);
          };


          sub pcheby {
          return CM::Polynomial::Chebyshev->new(@_);
          };

          sub gsym {
          return CM::Group::Sym->new({n=>$_[0]});
          };

          sub galt {
          return CM::Group::Altern->new({n=>$_[0]});
          };


          # to be removed when * implemented for groups
          sub gx {
          return CM::Group::Product->new({n=>1,groupG=>$_[0],groupH=>$_[1]});
          };

          sub gadd {
          return CM::Group::ModuloAddition->new({n=>$_[0]});
          };

          sub gmul {
          return CM::Group::ModuloMultiplication->new({n=>$_[0]});
          };

          sub gdih {
          return CM::Group::Dihedral->new({n=>$_[0]});
          };

          sub q {
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
