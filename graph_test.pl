use Graph::Directed;
# note: do not confuse Rubik's edges with graph's edges.

# graph of movement for edges of the Rubik's cube
my $h = Graph::Directed->new;

# This is built in order to find the sortest move combination to bringing an Rubik edge from a certain position
# to some other position.
#
# After 2 edges have been positioned the movement range should be limited by taking out some graph edges(does Graph.pm allow that ?).
#
# This should be helpful for solving the cross(first step in solving the bottom layer)




sub cycle {# graph cycle of 4 edges
	$h->add_edge($_[0],$_[1]);
	$h->add_edge($_[1],$_[2]);
	$h->add_edge($_[2],$_[3]);
	$h->add_edge($_[3],$_[0]);
};


# graph edges
cycle(2  , 4  , 8  , 6  )  ; cycle(49 , 22 , 31 , 13 )  ;#F
cycle(11 , 13 , 17 , 15 )  ; cycle(38 , 29 , 2  , 47 )  ;#D
cycle(22 , 20 , 24 , 26 )  ; cycle(53 , 8  , 35 , 44 )  ;#U
cycle(44 , 40 , 38 , 42 )  ; cycle(24 , 33 , 15 , 51 )  ;#B
cycle(49 , 47 , 51 , 53 )  ; cycle(20 , 40 , 11 , 4  )  ;#L
cycle(31 , 35 , 33 , 29 )  ; cycle(26 , 6  , 17 , 42 )  ;#R



