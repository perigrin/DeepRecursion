package DeepRecursion::Resource::Session;
use Moose;
extends "Magpie::Resource::Kioku";

use Magpie::Constants;
use Try::Tiny;
use Plack::Session;
use Data::Dumper::Concise;
use Digest::SHA;

sub GET {
    my $self = shift;

    if ( my $action = $self->request->param('logout') ) {
        return $self->DELETE;
    }

    return OK;
}

sub DELETE {
    my $self    = shift;
    my $session = Plack::Session->new( $self->request->env );
    $session->expire;
    $self->response->redirect('/login');
    return DONE;
}

sub POST {
    my $self = shift;
    my $ctxt = shift;
    my $req  = $self->request;

    my $session  = Plack::Session->new( $req->env );
    my $username = $req->param('username');
    my $password = $req->param('password');

    my $user = undef;

    try {
        $user = $self->data_source->lookup("user:${username}");
    }
    catch {
        my $error = "Could not GET data from Kioku data source: $_\n";
        $self->set_error( { status_code => 500, reason => $error } );
    };

    return OK if $self->has_error;

    unless ($user) {
        $self->set_error(404);
        return OK;
    }

    unless ( $user->check_password($password) ) {
        $self->set_error(403);
        return OK;
    }

    $session->set( user => $user );
    $self->state('created');
    $self->response->status(303);
    $self->response->header( 'Location' => '/' );
    return DONE;
}

1;
