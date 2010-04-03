# to compile PDL you need to install the following packages on Ubuntu/Debian libglut3-dev freeglut3-dev libxmu-dev
package CM::Polynomial::Discriminant;
use Moose::Role;
use PDL;
use PDL::Matrix;
use Math::Pari qw(factorint PARI); 
#use 5.008;
use feature 'say';
use Data::Dumper;
use strict;
use warnings;
use Carp qw/confess/;

requires 'coefficients';
requires 'degree';
requires 'coeff';

############################################################################################
#This role equips a class with an algorithm for calculating the discriminant of a polynomial
#
#This will be used with Eisenstein's criterion to determine appropriate shifts
############################################################################################



# only for polynomials in Q[X]
sub discriminant {
    my ($self) = @_;

    my @rows;
    my $n = $self->degree;
    #say $n;

    my @line = reverse $self->coefficients;
    my @line2 = @line;

    push @line,0 for 1..$n-2;


    #  @line will be transformed along the way and it will
    #  take the value of the rows 1 -> n-1
    #
    #  a_-i will mean a_{n-i}
    #
    #  a_n a_-1 a_-2 a_-3 ... a2   a1   a0    0  ... ... 0 
    #  0   a_n  a_-1 a_-2 ... a3   a2   a1   a0  ... ... 0 
    #  .
    #  .
    #  .
    #  0   0   ...           a_n a_-1 a_-2 a_-3         a0
    #
    #  these are the first n-1 rows

    for(1..-1+$n)  {
        push @rows,[@line];

        pop @line;
        unshift @line,0;
    };

    # the following will be the last n lines
    # @line2 will be transformed into all the rows from row n to the last row(2n-1)
    #
    # again a_-i means as stated above
    #
    # n*a_n (n-1)a_-1  (n-2)a_-2  (n-3)a_-3 ... 2*a2     a1          0      0  ... ... 0 
    # 0     n*a_n      (n-1)a_-1  (n-2)a_-2 ... 3*a3   2*a2         a1      0  ... ... 0 
    # 0     0             n*a_n   (n-1)a_-1 ... 4*a4   3*a3       2*a2     a1  ... ... 0 
    # .
    # .
    # .
    # 0     0                             0 ...    0  n*a_n  (n-1)a_-1         ... ...a1 


    @line2 = map { ($n-$_)*$line2[$_] } 0..-1+@line2; #actually dot product of  (n,n-1,...,1,0) and (a_n,a_{n-1},a_{n-2},...,a_1,a_0)
    push @line2,0 for 1..$n-2;


    for(1..$n) {
        push @rows,[@line2];

        pop @line2;
        unshift @line2,0;
    };


    #print Dumper \@rows;
    return (-1)**( ($n*($n-1)/2)%2 ) * mpdl([@rows])->det/$self->coeff($self->degree);
}

sub primes {
    my ($self,$n) = @_;
    print "factoring $n ...\n";
    my $f = factorint($n);
    $f =~ s/\[|\]|\(|\)|Mat//g;
    my @factors = map { /^(.*),/} split(';',$f);
    #print join("\n",@factors);
    #print "\n---------------\n";
    return @factors;
}

sub shifts {
    my ($self) = @_;
    my $disc = $self->discriminant;
    return $self->primes($disc);
}





1;
