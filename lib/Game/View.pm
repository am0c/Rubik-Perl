package Game::View;
use Moose;
extends 'Rubik::View';

override 'KeyboardCallback' => sub {
    my ($self) = @_;
    return sub {};
}






