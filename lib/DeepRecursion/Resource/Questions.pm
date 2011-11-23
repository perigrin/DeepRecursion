package DeepRecursion::Resource::Questions;
use Moose;
extends "Magpie::Resource::Kioku";

has '+wrapper_class' => ( default => 'DeepRecursion::Model::Question', );

1;
__END__
