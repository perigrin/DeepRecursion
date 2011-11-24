package DeepRecursion::Resource::User;
use Moose;
extends "Magpie::Resource::Kioku";

use KiokuX::User::Util qw(crypt_password);
use Magpie::Constants;
use Try::Tiny;

has '+wrapper_class' => ( default => 'DeepRecursion::Model::User', );

sub POST {
    my $self = shift;
    $self->parent_handler->resource($self);

    my $req           = $self->request;
    my $wrapper_class = $self->wrapper_class;

    my $id       = undef;
    my $to_store = undef;

    # XXX should check for a content body first.
    my %args = ();

    if ( $self->has_data ) {
        %args = %{ $self->data };
        $self->clear_data;
    }
    else {
        for ( $req->param ) {
            $args{$_} = $req->param($_);
        }
    }

    try {
        Class::MOP::load_class($wrapper_class);
        $to_store = $wrapper_class->new(
            id       => delete $args{username},
            password => crypt_password( delete $args{password} ),
        );
    }
    catch {
        my $error
            = "Could not create instance of wrapper class '$wrapper_class': $_\n";
        $self->set_error( { status_code => 500, reason => $error } );
    };

    return DECLINED if $self->has_error;

    try {
        $id = $self->data_source->store($to_store);
    }
    catch {
        my $error = "Could not store POST data in Kioku data source: $_\n";
        warn $error;
        $self->set_error( { status_code => 500, reason => $error } );
    };

    return DECLINED if $self->has_error;

    $self->state('created');
    $self->response->status(303);
    $self->response->header( 'Location' => "/user/$id" );
    return OK;
}

1;
__END__
