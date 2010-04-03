package main;
use CM::Polynomial::Irreducible qw/gen_ired/;
use Test::More qw/no_plan/;

my $p = CM::Polynomial::Irreducible->new(10,0,15,0,3);

ok(join(",",$p->primes_upto(3)) eq '2,3','primes_upto works ok');
ok($p->eisenstein==1,$p.' is irreducible');
#print $p->get_shifted(3);

sub test_eis {
    my ($irreducible) = shift @_;
    my $p= CM::Polynomial::Irreducible->new(@_); 
    ok($p->eisenstein==$irreducible,($irreducible?'ireducible ':'not eisenstein ').$p);
}

sub test_per {
    my ($irreducible) = shift @_;
    my $p= CM::Polynomial::Irreducible->new(@_); 
    ok($p->perron==$irreducible,($irreducible?'ireducible ':'perron cannot be applied').$p);
    return $p;
}

test_eis(1,2,1,1);# the polynomial X^2 + X + 2 will be shifted with change of variable X |==> X+3
test_eis(1,-2,0,0,0,0,0,0,0,0,0,0,0,0,0,1);
test_eis(1,-2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1);
test_eis(1,12,-6,12,-18,6,-30,1);
test_eis(0,1,2,1);    #
test_eis(0,6,11,6,1); # Eisenstein cannot be applied to this polynomial (X+1)(X+2)(X+3)


#####################################################################################################
#tests for Cyclotomic polynomials
#####################################################################################################
test_eis(1,1,1,1,1,1,1,1);
test_eis(1,1,1,1,1,1,1,1,1,1,1,1);
test_eis(1,1,1,1,1,1,1,1,1,1,1,1,1,1);
test_eis(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1);


#####################################################################################################
#Tests for Perron's criterion
#####################################################################################################
test_per(1,1,0,0,0,0,0,0,10,1); # first part
test_per(0,0,0,0,0,0,0,0,10,1); # first part
test_per(1,1,1,3,1); # satisfies the second part of Perron criterion
test_per(0,-1,-1,3,-1); # does not satisfy because p(1) = 0

print gen_ired(5);
