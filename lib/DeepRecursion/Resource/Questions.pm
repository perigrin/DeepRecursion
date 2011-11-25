package DeepRecursion::Resource::Questions;
use Moose;
extends "Magpie::Resource::Kioku";

use Magpie::Constants;
use Try::Tiny;
use Plack::Session;

has '+wrapper_class' => ( default => 'DeepRecursion::Model::Question', );

around POST => sub {
    my ( $next, $self ) = ( shift, shift );

    my $user = Plack::Session->new( $self->request->env )->get('user');
    unless ($user) {
        $self->set_error( { status_code => 403, reason => 'Not Logged In' } );
        return DONE;
    }

    $self->request->parameters->add( author => $user );

    my $return = $self->$next(@_);
    return $return unless $return == OK;

    $self->response->status(303);
    return OK;
};

1;
__END__
