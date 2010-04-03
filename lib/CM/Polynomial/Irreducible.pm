# maybe this should be a role and we apply it at runtime to a poly we want to check and then
# remove it after the check's been made...


package CM::Polynomial::Irreducible;
use strict;
use warnings;
use Math::Symbolic;
use Moose;
use Data::Dumper;
#use MooseX::NonMoose;
extends 'Math::Polynomial';
use Math::BigInt qw/bgcd/;
use Math::Primality qw/:all/;
use List::AllUtils qw/max min any all sum/;
#with 'Math::Polynomial::Discriminant';

=pod

=head1 NAME

CM::Polynomial::Irreducible - A module which implements various methods or criterions for testing irreducibility of polynomials in Z[X]

=head1 DESCRIPTION

=head1 BIBLIOGRAPHY

1) Victor V. Prasolov - Polynomials

=head1 AUTHOR

Stefan Petrea, C<< <stefan.petrea at gmail.com> >>
=cut


require Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
push @ISA,'Exporter';
$VERSION     = 0.01;
@EXPORT_OK = qw(gen_ired);

#Definition of irreducible element: a non-unit in an integral domain is said to be irreducible if it is not a product of two non-units.
#Eisenstein's criterion is a method to determine if a certain polynomial over a field is irreducible.


#use constant for debug
#ask if it's good to inherit without NonMoose although ::Polynomial doesn't use Moose ?

sub primes_upto {
    # normally should decompose n and take the primes
    my ($self,$n) = @_;
    $n="$n";
    my $i = 1;
    my @primes = ();
    while(1) {
        $i=next_prime($i);
        last if $i>$n;
        push @primes,$i;
    };
    @primes;
}


#####################################################################################################
#evaluate polynomial over Z_n[X] and if one value of 
#####################################################################################################

sub eval_modulo {
    my ($self) = @_;
}



#####################################################################################################
#This method implements Eisenstein's criterion
#
#Returns:
#1 - the polynomial is irreducible
#0 - eisenstein cannot be applied to it, so in the case it returns 0 nothing can be said
#    about the polynomial using Eisenstein(wether it's irreducible or not)
#    this return value may also mean that the shift needed is bigger than $max_shift
#
# TODO: add discrimnant function for polynomial and let the p checked be only divisors 
# of the discriminant
#####################################################################################################

sub eisenstein {
    # Implements Eisenstein for polynomials in Z[X]
    my ($self) = @_;

    my $max_shift = 100; # maximum number of shifts after which we give up
    # for certain polynomials we will do a shift(change of variable) to ensure we can use the Eisenstein criterion
    # we shift until the polynomial is not primitive any more so that p can exist

    sub gcd_coeffs {
        my $p = $_[0];
        my @coeffs = $p->coefficients;
        pop @coeffs; # dominant coefficient need not be divisible with p
        #print join(',',@coeffs)."\n";
        #print "gcd:".bgcd(@coeffs)."\n";
        bgcd(@coeffs);
    };

    # if there is a shift for which there might be a prime p, then use that shift and see if there's a p statisfying the conditions
    my $shifted;
    my $gcd = gcd_coeffs($self);
    if($gcd==1) {
        my $shiftp = 1;#how much to shift
        $shifted = $self;
        for my $shiftp (1..$max_shift+1) {
            #print "shifting with $shiftp\n";
            $gcd = gcd_coeffs($shifted);
            last if $gcd != 1;
            #print "shiftp: $shiftp\n";
            #<>;
            $shifted = $self->get_shifted($shiftp++);
            return 0 if $shiftp > $max_shift;# only allow 100 shifts
        };
    };
    $self = $shifted if $shifted;
    print $self."\n";
    my $dominant	= $self->coeff($self->degree);
    my $free	= $self->coeff(0);
    return any {
        my $p = $_;

        $dominant % $p	!= 0 &&
        $free % $p**2	!= 0 &&
        (
            all { 
                #print $self->coeff($_)."\n";
                $self->coeff($_) % $p == 0; 
            } 0..-1+$self->degree
        );
        # max( |a_i| )
    } $self->primes_upto( $gcd )
}



#####################################################################################################
# get_shifted shifts a polynomial by making the change of variable
# X |-> X + constant
#####################################################################################################

# could use Pascal triangle to optimize(but probably nested already does this?)
sub get_shifted {
    my ($self,$constant) = @_;# X |----> X+$constant
    return $self->nest(CM::Polynomial::Irreducible->new($constant,1));
}


#####################################################################################################
# Perron's criterion
# 1 if irreducible
# 0 if cannot be applied(again, nothing can be said here)
#
# TODO: if bgcd($self->coefficients) == $self->coeff($self->degree) then divide all by the gcd and 
# apply the criterion
#####################################################################################################

sub perron {
    my ($self) = @_;
    #pre-conditions
    return 0 if
        $self->coeff($self->degree) != 1 ||
        $self->coeff(0)==0;

    my @ai = $self->coefficients;
    pop @ai;
    my $a1 = pop @ai;

    #the actual criterion
    return
        ( $a1 >  1 + sum(@ai) ) ||
        ( $a1 >= 1 + sum(@ai) && ( $self->evaluate(1)!=0 || $self->evaluate(-1)!=0 ) );
}





# produce an irreducible over Q[X] of degree n
# X^n - p is irreducible in Q[X]

sub gen_ired {
    my ($n) = @_;
    my @coeffs = (-7);#some prime
    push @coeffs,0 for 1..$n-1;
    push @coeffs,1;
    return CM::Polynomial::Irreducible->new(@coeffs);
}



1;
