package DeepRecursion::Resource::User;
use Moose;
extends "Magpie::Resource::Kioku";

has '+wrapper_class' => ( default => 'DeepRecursion::Model::User', );

1;
__END__
