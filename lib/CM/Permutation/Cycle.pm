package CM::Permutation::Cycle;
use Moose;
use List::AllUtils qw/min max first true/;
use Data::Dumper;
#use feature 'say';
use Carp;

extends 'CM::Permutation';

#note: if you overload in base class you don't need to overload again in derived class
use overload "=="=> 'equal', # it's better to use sub names instead of coderefs
             '""'=> 'stringify_cycle', # "" and == are used by uniq from List::AllUtils in the tests
             '*' => 'multiply';   


has cycle_elements => (
    isa  => 'ArrayRef[Int]',
    is  => 'rw',
    default => sub {[]},
);


sub BUILDARGS {
    my ($self,@args) = @_;

    my @a = 0..max(@args);


    if(@args>1) {
        map {
            my $i = $args[ $_   ];
            my $j = $args[ $_+1 ];
            #       say "$i $j";
            $a[$i] = $j;
        } 0..-2+@args;
        #say "$args[-1] $args[0]";
        $a[ $args[-1] ] = $args[0];
    }


    {
        perm            => \@a,
        cycle_elements  => \@args
    };
}

sub stringify_cycle {
    my($self) = @_;
    return '('.@{$self->cycle_elements}.')'
        if(@{$self->cycle_elements}==1);

    my @v = @{$self->perm};
    my @elem;
    my $current = first { $_!=$v[$_] } 1..-1+@v;
    my $start = $current;
    while(1){
        $current = $self->perm->[$current];
        push @elem,$current;
        last if $current == $start;
    };
    return '('.join(',',@elem).')';
}


sub BUILD {
    my($self,@args) = @_;
    # check @args has enough arguments
}

#override 'order' => 

sub order {# the order of a cycle is its length
    my ($self) = @_;
    return 1
        if(@{$self->cycle_elements}==1);
    my @v = @{$self->perm};
    #print Dumper $self->perm;
    return true { $_ != $v[$_] } 1..-1+@v ;
};


# multiply at the same time overloads * operator and also
# overrides the multiply from CM::Permutation
around 'multiply' => sub {
    my ($orig,$right,$left) = @_;

    my $rmax = max(@{ $right->perm });
    my $lmax = max(@{  $left->perm });
    my $max = max($rmax,$lmax);

    if(     $rmax<$lmax){
        $right->perm->[$_] = $_
            for $rmax+1..$lmax;
    }elsif( $lmax<$rmax){
         $left->perm->[$_] = $_
            for $lmax+1..$rmax;
    };

    return $right->$orig($left);
};







1;
