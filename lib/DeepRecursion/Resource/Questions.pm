package DeepRecursion::Resource::Questions;
use Moose;
extends "Magpie::Resource::Kioku";

has '+wrapper_class' => ( default => 'DeepRecursion::Model::Question', );

sub _build_data_source {
    my $self = shift;
    my $k = $self->resolve_asset( service => 'kioku_dir' );
    $self->_kioku_scope( $k->new_scope );
    return $k;
}

1;
__END__
