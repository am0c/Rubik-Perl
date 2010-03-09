package CM::Tuple;
use MooseX::Role::Parameterized;
use overload    "*" => \&multiply;
parameter 'first_type' => ( isa   => 'Str' );
parameter 'second_type' => ( isa   => 'Str' );

role {
    my $p = shift;
    my $f_type = $p->first_element;
    my $s_type = $p->first_element;

    has first => (
	    isa	=> $f_type,
	    default => undef,
	    required => 1,
    );

    has second => (
	    isa	=> $f_type,
	    default => undef,
	    required => 1,
    );

    method multiply => sub {
	    my ($op1,$op2)=@_;
	    $p->new(
		    {
			    first => $op1->first  * $op2->first  ,
			    second=> $op1->second * $op2->second ,
		    }
	    );
    };
};

1;
