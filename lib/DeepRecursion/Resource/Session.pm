package DeepRecursion::Resource::Session;
use Moose;
extends qw(Magpie::Resource::Session);
use Magpie::Constants;

before DELETE => sub { warn "DELETE!!!" };

after GET => sub {
    my $self = shift;
    $self->response->redirect('/');
};

around POST => sub {
    my ( $next, $self ) = ( shift, shift );

    my $return = $self->$next(@_);
    return $return unless $return == DONE;

    my $id = $self->session->id;
    $self->response->status(303);
    $self->response->header(
        'Location' => $self->request->base . "sessions/$id" );
    return DONE;
};

1;
__END__
