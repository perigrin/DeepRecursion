package DeepRecursion::Transformer::JSON;
use Moose;
extends 'Magpie::Transformer';
use Scalar::Util qw(blessed);
use Magpie::Constants;
use JSON::Any;

__PACKAGE__->register_events(qw(transform));

sub load_queue { return qw(transform) }

sub transform {
    my $self = shift;
    
    return DECLINED if $self->resource->isa('Magpie::Resource::Abstract');
    
    if ( $self->resource->has_data ) {
        my $data        = $self->resource->data;
        my $json_string = undef;
        if ( blessed $data && $data->does('Data::Stream::Bulk') ) {
            my @objects = ();
            while ( my $block = $data->next ) {
                foreach my $object (@$block) {
                    push @objects, JSON::Any->encode($object);
                }
            }
            $json_string = '[' . ( join ', ', @objects ) . ']';
        }
        else {
            $json_string
                = JSON::Any->new( allow_blessed => 1 )->encode($data);
        }
        $self->response->content_type('application/json');
        $self->response->content_length( length($json_string) );
        $self->resource->data($json_string);
    }

    return OK;
}

1;
__END__
