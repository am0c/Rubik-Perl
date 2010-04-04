package Disc;
use Moose;
extends 'Math::Polynomial';
with 'CM::Polynomial::Discriminant';

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
use CM::Polynomial::Irreducible;

use CM::Permutation::Cycle_Algorithm;
use Moose;
use Devel::REPL;
use namespace::clean -except => [ qw(meta) ];

has '_repl' => (
  is => 'ro', isa => 'Devel::REPL', required => 1,
  default => sub { 
      
      my $r = Devel::REPL->new();
      # TODO: find a way for completion to work with Devel::REPL, tried the listed plugins, and they didn't work
      $r->load_plugin($_) for qw(History LexEnv );#MultiLine::PPI CompletionDriver::Keywords CompletionDriver::Methods);
      $r->eval('
          use Math::Polynomial::Solve qw(poly_roots);

          sub help {
          "

                  mathshell is a shell for the modules in the CM::Permutation distribution
                  all the operations implemented on these objects are available(check their pod/source for details)

                  permutations:
                  ------------

                  cycle         - permutation cycle
                  perm          - permutation
                  decomp        - decompose a permutation into cycles
                  randpermn     - returns an array with the numbers fro 1..n permuted in a random way

                  polynomials:
                  -----------

                  pcyclo        - nth cyclotomic polynomial
                  pcheby        - nth chebyshev polynomial
                  pgen          - generates a polynomial given the coefficients
                  roots         - gets all the complex roots of a polynomial
                  eisenstein    - eisenstein test
                  perron        - perron     test
                  discriminant  - compute discriminant

                  groups:
                  ------

                  gsym          - S_n
                  galt          - A_n
                  gdih          - D_2n
                  gadd          - (Z_n,+)
                  gmul          - (Z_n,*)
                  gx            - group product
                  elements      - elements of the group

                  Ex:  
                  gsym(3)->compute()
                  pgen(3,2,1)
                  3 + 2X + X^2

          ";
          }

          ###################################################################
          ### PERMUTATIONS

          sub perm {
          return CM::Permutation->new(@_);
          };

          sub cycle {
          return CM::Permutation::Cycle->new(@_);
          };
          
          sub decomp {
              my $arg = shift;
              my @a = @{$arg->perm};
              shift @a;
              my $alg = CM::Permutation::Cycle_Algorithm->new(@a);
              $alg->run;
              return $alg;
          }

          ###################################################################
          ### POLYNOMIALS

          sub pcyclo {
              return CM::Polynomial::Cyclotomic->new(@_);
          };


          sub pcheby {
              return CM::Polynomial::Chebyshev->new(@_);
          };

          sub pgen {
              return Math::Polynomial->new(@_);
          };

          sub roots {
              my $p = $_[0];
              return join(
                  "\n",
                  poly_roots($p->coefficients)
              );
          };

          sub eisenstein {
              my $p = shift;
              my $w = CM::Polynomial::Irreducible->new($p->coefficients);
              return $w->eisenstein;
          };

          sub perron {
              my $p = shift;
              my $w = CM::Polynomial::Irreducible->new($p->coefficients);
              return $w->perron;
          };

          ###################################################################
          ### GROUPS

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

          sub elements  {
              my $s = shift;
              $s->compute_elements->();
              print join("\n",@{$s->elements});
              print "\n";
          };

          sub discriminant {
              my $d = shift;
              return Disc->new($d->coefficients)->discriminant;
          };

          sub randperm {
              my $r = ~~@_;
              map {  splice(@_,rand($r--),1);  } 1..$r;
          }

          sub randpermn {
              randperm(1..$_[0]);
          }



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
