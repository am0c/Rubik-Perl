package CM::Group;
use Moose::Util q/apply_all_roles/;
use MooseX::Role::Parameterized;
use Acme::AsciiArt2HtmlTable;
use Math::Polynomial;
use List::AllUtils qw/all first zip/;
use Carp;
use GraphViz;
use Text::Table;
use CM::Tuple;
use strict;
use warnings;
requires '_builder_order';
requires 'compute_elements';
requires 'operation'; # wrapper function over operation of elements , REM : whenever I do  * in a group method
                      # I should replace that with  $self->operation($arg1,$arg2)
parameter 'element_type' => ( isa   => 'Str' );


=head1 NAME

CM::Group - A parametrized role to abstract the characteristics of a group.


=head1 DESCRIPTION

This role will describe the general characteristics of a Group, its attributes, and as much as
can be abstracted from the current implementation.

This role will be instantiated with the parameter element_type being the type of the elements that the group
will contain.

=head1 SYNOPSIS


    pacakge SomeGroup;
    use Moose;
    with 'CM::Group' => { element_type => 'GroupElement'  };
    
    sub _builder_order {
      # order of the group is computed here
    }
    sub compute_elements {
      # the elements are computed here
    }
    sub operation { 
      # group operation is defined here (it's usually a wrapper of the "*" operator of GroupElement)
    }


=head1 AUTHOR

Stefan Petrea, C<< <stefan.petrea at gmail.com> >>

=cut



# parametrized roles are a lot like C++ templates

role {
    my $p = shift;

    my %args = @_;
    my $consumer = $args{consumer};

    my $T = $p->element_type;

    has n => (              # this will be related to the order of the group
        isa      => 'Int',
        is       => 'rw',
        default  => undef,
        required => 1,
    );


    # only used for assigning labels
    has tlabel  => (
	    isa     => 'Int',
	    is      => 'rw',
	    default => 1,
	    lazy    => 1,
    );

    has order   => (
        isa     => 'Int',
        is      => 'rw',
        lazy    => 1,
        builder => '_builder_order',
    );

    has operation_table => (
        isa             => "ArrayRef[ArrayRef[$T]]",
        is              => 'rw',
        default         => sub{[]},
    );

    has elements => (
        isa      => "ArrayRef[$T]",
        is       => 'rw',
        default  => sub {[]},
    );

    has computed => (
        isa      => "Bool",
        is       => 'rw',
        default  => 0,
    );

    # generating polynomial of group
    # Adventures in Group Theory - David Joyner 2nd edition
    method gen_polynomial => sub {
        my ($self) = @_;
        my @coeffs;
        $coeffs[$_->[0]->order()]++
            for $self->conj_classes_fast(); # count number of elements of different orders from each conj class
                                        # (in a conjugacy class every element has the same order)
        return Math::Polynomial->new( 0 , @coeffs );
    };

    method add_to_elements => sub {
        my ($self,$newone) = @_;

	confess "undefined passed" unless $newone;
	my $tlabel = $consumer->find_method_by_name('tlabel');

	my $tlabel_val =  $self->tlabel;

	$newone->label($tlabel_val);
        unshift @{$self->elements},$newone;

        croak "not all elements have labels"
        unless( all { defined($_->label) }(@{ $self->elements }) );

	$self->tlabel($self->tlabel() + 1);

	#$tlabel->execute( $tlabel->execute() + 1 );
    };

    method perm2label => sub {
        my ($self,$perm) = @_;
        my $found = first { 
            $_ == $perm;
        } @{$self->elements};

        return $found->label;
    };

    method label2perm => sub { };

    method cayley_digraph => sub {
        my ($self,$path,$generators) = @_;
        my $graph = GraphViz->new(
            center   => 1 ,
            ratio    => 'fill',
            width    => 9,
            height   => 9,
            layout   => 'fdp',
            directed => 0,
        );
        my @seen;
        my @colors = qw/green blue yellow/; # will need to add more colors (maybe 10 should suffice, for my needs I won't try to generate stuff with more than 10 generators)

        my %color = zip(@$generators,@colors);

        for my $x (@{$self->elements}) {
            my $from = $x;
            for my $g (@$generators) {
                my $to   = $self->operation($x,$g);
                next if "$from,$to" ~~ @seen;
                $graph->add_edge(
                    "$from"   => "$to",
                    label     => "$g",
                    color     => $color{"$g"},
                    fontcolor => $color{"$g"},
                    style     => "setlinewidth(1.8)",
                );
                push @seen,"$from,$to";
                push @seen,"$to,$from";
            }
        };
        $graph->as_gif($path // "/var/www/docs/graph.gif");
    };

    method draw_diagram => sub {
        my ($self,$path) = @_;
        my $order = $self->order;
        my $graph = GraphViz->new(
            center => 1 ,
            ratio  => 'fill',
            width  => 30,
            height => 30,
            layout => 'twopi'
        );
        for my $i (0..-1+$order) {
            for my $j (0..-1+$order) {
                my $from    = $self->operation_table->[0]->[$j]->label;
                my $to      = $self->operation_table->[$i]->[$j]->label;
                my $with    = $self->operation_table->[$i]->[0]->label;
                #say "from=$from to=$to with=$with";
                $graph->add_edge(
                    $from => $to,
                    label => $with
                );
            }
        };
        $graph->as_png($path // "/var/www/docs/graph.png");
    };


# TODO: same thing as with compute, need to use Data::Alias for locals

# rearrange so that the identity element is always on the first diagonal

    method rearrange => sub {
        my ($self) = @_;
        my $order = $self->order;
        for my $y ( 0..-1+$order) {
            my $c = -1; #the column on which the identity sits on row $y

            local *ycol = \$self->operation_table->[$y];

            #identity element already in place so we skip this
            next if( ${*ycol}->[$y] == $self->identity);

            for my $x (0..-1+$order) {
                if( ${*ycol}->[$x] == $self->identity ) {
                    $c = $x;
                    last;
                };
            };


            #now swap the identity column with the column it should be on but only if needed
            my $tmp = ${*ycol};
            ${*ycol} = $self->operation_table->[$c];
            $self->operation_table->[$c] = $tmp;
        }
    };

    method draw_asciitable => sub {
         # this module shouldn't be in Acme namespace.. it's pretty useful
         #my $g = CM::Group::Sym->new({n=>4});

        my ($self,$file) = @_;

        my $alpha = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
        $self->compute unless $self->computed;

        $self->rearrange; # rearrange elements so identity sits on first diagonal so we can see the symmetries properly

        my $table = "$self";

        print "$table\n";
        
        # the identity element needs to be on the first diagonal if we're going to make any sense out of this

        $table =~ s/(\d+)/substr($alpha,$1,1)/ge;
        $table =~ s/( )+//g; # get spaces out of the way

        my $html = aa2ht( { 
                            'randomize-new-colors' => 1 ,
                            'td'                   => 
                                                    {
                                                    'width'  => '20px',
                                                    'height' => '20px'
                                                    }
                          }, $table);

        open my $fh,">$file";

        print $fh $html;
    };

    method compute => sub {
        my ($self) = @_;

        return $self if $self->computed;

        $self->compute_elements();

        print "number of elements".scalar(@{$self->elements})."\n";

        croak "not all elements are defined"
        unless( all { defined($_) }(@{ $self->elements }) );


        # TODO: the locals need to be fixed using Data::Alias...
        my $order = $self->order;
        # *ij is actually an alias(typeglob) to $self->operation_table->[$i]->[$j]
        for my $i (0..-1+$order) {
            for my $j (0..-1+$order) {
                local *i  = \$self->elements->[$i];
                local *j  = \$self->elements->[$j];
                local *ij = \$self->operation_table->[$i]->[$j];

                croak "one of multiplication arguments is undefined $i  $j"
                unless defined(${*i}) && defined(${*j});


                ${*ij} = $self->operation(${*i},${*j});

                croak "result is undefined"
                unless defined(${*ij});

                ${*ij}->label($self->perm2label(${*ij}));
            }
        };
        $self->computed(1);

        return $self; # to be able to chain
    };

    method stringify => sub {
        my ($self) = @_;
        my $table = Text::Table->new;
        my $order = $self->order; #reduce { $a * $b  } 1..$self->n;
        my @for_table;
        for my $i (0..-1+$order) {
            my @new_line = map{ $_->label  } @{$self->operation_table->[$i]};
            push @for_table,\@new_line;
        }
        $table->load( @for_table );
        return "$table";
    };
    
    method group_product => sub {
	    my ($G,$H) = @_;

	    # some nice info on this here as well
	    # http://stackoverflow.com/questions/1758884/how-can-i-access-the-meta-class-of-the-module-my-moose-role-is-being-applied-to

	    my ($typeG) = ref($G) =~ /::([^:]*)$/;
	    my ($typeH) = ref($H) =~ /::([^:]*)$/;
	    my $cardG = $G->n;
	    my $cardH = $H->n;

	    my $product_group = Moose::Meta::Class->create(
		    __PACKAGE__,#"CM::Group::Product::$typeG$cardG$typeH$cardH",
		    #superclasses => ['Moose'], # not sure here yet

	    );


	    $product_group->meta->make_mutable;
	    # store these inside the group so he can access them when he needs to 
	    # compute the elements. (could have used a closure but prefered not to)

	    $product_group->meta->add_attribute("prod_groups"=>(
			    default => sub{ [$G,$H] },
			    isa => 'Any',
			    is => 'rw',
			    reader  => 'prod_groups',
			    lazy => 1,
		    ));

	    apply_all_roles(
		    $product_group,
		    'CM::Group',
		    { element_type => "CM::Tuple" }
	    ); # apply CM::Group to the newly created group

	    #confess "cannot find tlabel" unless $product_group->tlabel;
	    #exit;


	    $product_group->meta->add_method(
		    compute_elements => sub {
			    my ($self) = @_;
			    my @elements;

			    my $add_to = $consumer->find_method_by_name('add_to_elements');
			    #print ref $add_to;
			    #$add_to->execute('CM::Group','asdasd');
			    #exit;

			    confess "undefined prod_groups" unless $self->prod_groups;

			    $self->prod_groups->[0]->compute_elements
			    if(!@{$self->prod_groups->[0]->elements});

			    $self->prod_groups->[1]->compute_elements
			    if(!@{$self->prod_groups->[1]->elements});

			    for my $g (@{$self->prod_groups->[0]->elements}) {
				    for my $h (@{$self->prod_groups->[1]->elements}) {
					    my $to_add = CM::Tuple->new({
								    first=>$g,
								    second=>$h
							    }
						   	 );
					    confess 'one was undef' unless defined $to_add;
					    $add_to->execute(
						    $to_add
					    );
				    };
			    };
		    }
	    );

	    # or use __PACKAGE__->meta->apply instead ?

	    return $product_group;
    };

   
    
    #cartesian product of 2 groups


    #   #http://en.wikipedia.org/wiki/Direct_product
}
