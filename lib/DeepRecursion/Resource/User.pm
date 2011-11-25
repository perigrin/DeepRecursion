package DeepRecursion::Resource::User;
use Moose;
extends "Magpie::Resource::Kioku";

use KiokuX::User::Util qw(crypt_password);
use Magpie::Constants;
use Try::Tiny;

has '+wrapper_class' => ( default => 'DeepRecursion::Model::User', );

around POST => sub {
    my ( $next, $self ) = ( shift, shift );

    my $username = $self->request->param('username');
    my $password = crypt_password( $self->request->param('password') );
    $self->request->parameters->add( id       => $username );
    $self->request->parameters->add( password => $password );

    my $return = $self->$next(@_);
    return $return unless $return == OK;

    $self->response->status(303);
    return OK;
};

1;
__END__
