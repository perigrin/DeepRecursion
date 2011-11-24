package DeepRecursion::Resource::Answers;
use Moose;
extends "Magpie::Resource::Kioku";

use Magpie::Constants;
use Try::Tiny;
use Plack::Session;

has '+wrapper_class' => ( default => 'DeepRecursion::Model::Answer', );

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

    my $user = Plack::Session->new( $req->env )->get('user');
    unless ($user) {
        $self->set_error( { status_code => 403, reason => 'Not Logged In' } );
        return DONE;
    }

    my ($question_id) = ( split '/', $req->path_info )[-2];

    try {
        Class::MOP::load_class($wrapper_class);
        $to_store = $wrapper_class->new(
            author => $user,
            title  => $args{title},
            text   => $args{text},
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
        my $question = $self->data_source->lookup($question_id);
        $question->add_answer($to_store);
        $self->data_source->store($question);
    }
    catch {
        my $error = "Could not store POST data in Kioku data source: $_\n";
        warn $error;
        $self->set_error( { status_code => 500, reason => $error } );
    };

    return DECLINED if $self->has_error;

    $self->state('created');
    $self->response->status(303);
    $self->response->header( 'Location' => "/questions/$question_id" );
    return OK;
}

1;
__END__
