use strict;
use warnings;
use Test::More;
BEGIN{ 
    eval "use OpenGL";
    plan skip_all => "OpenGL required for testing Rubik::Model" if $@;
};
use Rubik::Model;
use Rubik::View;


my $view = Rubik::View->new();
my $model= Rubik::Model->new({view=>$view});


my @pair1 = (25,26,27,23);
my @pair2 = (25,26,27,41);
my @pair3 = (25,26,27,14);
ok($model->same_face(@pair1),"same_face");
$model->move('R');
ok(!$model->same_face(@pair1),"not on the same_face any more");
ok($model->same_face(@pair2),"but now these are on the same face");
$model->move('R');
ok(!$model->same_face(@pair2),"now they are no more because we rotated");
ok($model->same_face(@pair3),"but now these are on the same face");


done_testing;

#print $model;
