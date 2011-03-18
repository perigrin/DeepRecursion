package DeepRecursion::User;
use Moose;
use DateTime;

with qw(KiokuX::User);

has timestamp => (
    isa     => 'DateTime',
    is      => 'ro',
    default => sub { DateTime->now }
);

1;
__END__
