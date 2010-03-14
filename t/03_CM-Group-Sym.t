use strict;
use warnings;
use lib './lib/';
use CM::Permutation::Cycle;
use CM::Permutation;
use CM::Group::Sym;
use Data::Dumper;
#use feature 'say';
use Test::More;
use List::AllUtils qw/each_array each_arrayref reduce sum uniq true/;
use Test::Deep qw/cmp_deeply bag set ignore/;


# TODO: to replace fac with bfac from Math::BigInt


sub fac {
    return 1 if !$_[0];
    return 1 unless $_[0];
    reduce { $a * $b } 1..$_[0];
}

sub p{
    CM::Permutation->new(@_);
}

sub print_classes {
        my $i=0;
        map {
            print "CLASS ".$i++,"\n";
            map {
                print "$_\n";
            } @$_
        } @_;
}


sub test_group {
    my ($n) = @_;
    print "==Tests for group S_$n==\n";
    my $g = CM::Group::Sym->new({n=>$n});

    $g->compute();



    my @all = map { @{$_} } 
    @{$g->operation_table};

# we know |S_3| = 3! = 6   so we're going to use that as a test
    ok(scalar(uniq(@all))==$g->order,'the order of g is right');


    

    my @ug;

    @ug = map { $g->get_inverse($_) } 1..$g->order;
#if labelling is changed this test has to be changed as well
    my $table = "$g";
    if($n==3) {
    ok($table eq
        qq{6 5 4 3 2 1
5 6 3 4 1 2
4 1 2 5 6 3
3 2 1 6 5 4
2 3 6 1 4 5
1 4 5 2 3 6
},'operation table for S_3 computed correctly');

    ok($g->str_perm eq
qq{6 -> 1 2 3
5 -> 1 3 2
4 -> 3 1 2
3 -> 2 1 3
2 -> 2 3 1
1 -> 3 2 1},'permutation labels are ok');
    
    
        my @expected = (1,4,3,2,5,6);
        
        ok( @ug ~~ @expected , 'group inverses for S_3') if $n == 3; # every element in the group has its inverse
        ok( ~~@ug == $g->order , 'every element in the group is inversable ');

    };

    is
    ( 
        $g->perm2label(
            CM::Permutation->new(2,3,1)
        ),
        2,
        'perm2label works ok'
    ) if $n==3;





    # S_n is not commutative, and we're going to verify that
    my $commutative = 1;
    BOTH:
    for my $i (0..-1+$g->order) {
        for my $j (0..-1+$g->order) {
            my $p = $g->operation_table->[$i]->[$j]->label;
            my $q = $g->operation_table->[$j]->[$i]->label;
            if($p!=$q){
                $commutative = 0;
                last BOTH;
            }
        }
    };
    ok(!$commutative,"S_$n is not commutative");



    @ug = sort{ $a<=>$b }(uniq(@ug));
    my @labels = (1..$g->order);

    my $iter1 = each_array(@ug,@labels);
    my $res1 = 1;
    while( my ($a,$b) = $iter1->() ) {
        $res1 &= $a == $b;
    };

    ok( $res1  , "general group inverse test got ".join(" ",@ug)." inverses)");

#we have $g->order elements in the group and each has a label
    ok(   ( 1 == true { $g->idempotent($_) } ( 1..$g->order ) ) , 'only one idempotent');


    my @a = grep { $g->idempotent($_) } (1..$g->order);
    ok( CM::Permutation->new(1..$n) == $g->label_to_perm($a[0]) , 'the idempotent is exactly the identical permutation' );


# test equivalence classes(conjugacy classes actually)
  


    my @c = $g->conj_classes;
    my @c_fast = $g->conj_classes_fast;


    if($n==3) {
        # set() is not really useful here
        # it fails to make the test independent of the order of elements inside $g->elements
        # some Prolog-like matching would be needed to achieve this
        # however...we don't have that
        my $p1 = $g->elements->[0];
        my $p2 = $g->elements->[1];
        my $p3 = $g->elements->[3];
        my $p4 = $g->elements->[5];
        my $p5 = $g->elements->[2];
        my $p6 = $g->elements->[4];

        cmp_deeply(
            \@c,
            set(
                [$p1],
                set($p2,$p3,$p4),
                set($p5,$p6)
            ),
            "conjugation classes are fine"
        );
# show the equivalence classes


        #this test should be kept as last for the conjugacy class
        #tests because it will modify @c

    };


    @c = grep { !grep { $_ == $g->identity  } @{$_} } @c; 
    @c_fast = grep { !grep { $_ == $g->identity  } @{$_} } @c_fast; 
#    print_classes(@c);
    # take out the class with identity element, that will be counted by Z(G) anyway

    ok(
        $g->order == ~~($g->center) + sum(map { ~~@{$_} } @c)
        ,
        'Class equation verified'
    ); 

    ok(
        $g->order == ~~($g->center) + sum(map { ~~@{$_} } @c_fast)
        ,
        'Class equation verified for ->conj_classes_fast()'
    ); # see http://en.wikipedia.org/wiki/Class_equation#Conjugacy_class_equation


#    say;




    my @center = $g->center;
    if($n==4) {
		
		ok( $g->stabilizer(3) == 6 , "there are 6 elements in Stab(3)");

#        say "Center of S_4 is -> ".join(")(",@center);
        my $y = p(1,2,3,4);
        my $i = 0;

        ok(
            $_*$y==$y*$_,
            "centralizer of ($y) contains ($_)"
        ) for $g->centralizer($y);
        
        is(~~@center,1,"center of S_4 has just 1 element");
        ok($center[0]==p(1,2,3,4),'and that element is the identity permutation');

        # testing number of elements in conjugacy classes
    
        for my $class (@c_fast){
            # tests that in a conjugacy class of type lambda_1 lamda_2 ... lambda_k
            # there are exactly n! / ( lambda_1! lamda_2! ... lambda_k! 1^lambda_1 2^lambda_2 ... k^lambda_k) elements
            # where lambda_i are the number of cycles of length i in the type of element for that particular class
            # details in I. Tomescu[72] - Introduction to Combinatorics
            # (also related to Cycle index -> http://en.wikipedia.org/wiki/Cycle_index)
            my $r = $class->[0];
            my @type = (0) x ($n+1);
            map {
                $type[$_->order]++;
            } $r->get_cycles;

            my $expected = fac($n)/(
                reduce { $a * $b }
                map { fac($type[$_]) * ( $_**$type[$_] ) }
                1..-1+@type
            );
            ok(~~@$class == $expected, "conjugacy class @type has $expected number of elements");

        };
        my @normal_subgroups = $g->normal_subgroups;

        for my $H ( @normal_subgroups ) {
            my $res = 1;
            my $label;
            for my $x ( @{ $g->elements } ) {
                my @left_coset  = map { $x * $_ } @$H;
                my @right_coset = map { $_ * $x } @$H;
                my $H;
                $H->{"$_"} = 1
                    for @left_coset;
                $res &= $H->{"$_"} 
                    for @right_coset;
                $label  = join ';',@left_coset;
				# have checked if left_coset and right_coset basically contain the same elements
            };
            ok($res,"normal subgroup [[$label]]");
        };



        # tests for Dimino's algorithm
        my @elem    = $g->dimino(p(2,3,1,4),p(2,1,3,4));
        my @elem1   = $g->dimino(p(2,1,3,4),p(1,3,2,4),p(1,2,4,3));# transpositions (1,2) ; (2,3) ; (3,4) generate S_4
        ok(~~@elem==6   ,"the subgroup of S_4 generated by (2,3,1,4) and (2,1,3,4) has order 6");
        ok(~~@elem1==24  ,"it's a known fact that n-1 transposition generate S_n");
    };



    if ( $n == 5 ) {

        # "If an element of prime order divides the order of the group then the group must contain an element of that order"
        # http://en.wikipedia.org/wiki/Cauchy%27s_theorem_%28group_theory%29
        #
        #J. Rotman - An Introduction to the Theory of Groups - Theorem 4.2 page 74

        my $vec = Bit::Vector->new(6);
        $vec->Bit_On($_) for (2,3,5);
        for (@{$g->elements}) {
            last unless $vec->to_Dec; # break if it has unset all the bits, meaning it found all the needed orders
            my $ord = $_->order;
#            print "$ord\n";
            if($vec->contains("$ord")) {
#                print "FOUND element of order $ord\n";
                $vec->Bit_Off("$ord");
            };
        };
        ok(!$vec->to_Dec,'Cauchy theorem proved for S_5'); # $vec->to_Dec needs to be 0, if it's more than 0 then some orders haven't been found among the orders of elements of the group
    };

}




test_group $_ for 3..4;





done_testing();
