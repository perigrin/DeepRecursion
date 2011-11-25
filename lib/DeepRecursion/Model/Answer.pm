package DeepRecursion::Model::Answer;
use Moose;
use Digest::SHA qw(sha1_hex);
use DateTime;

has id => (
    isa     => 'Str',
    is      => 'ro',
    lazy    => 1,
    default => sub { sha1_hex( shift->text ) }
);

has text => (
    isa      => 'Str',
    is       => 'ro',
    required => 1,
);

has author => (
    isa      => 'DeepRecursion::Model::User',
    is       => 'ro',
    required => 1,
);

has votes => (
    isa     => 'ArrayRef[DeepRecursion::Model::User]',
    default => sub { [] },
    traits  => ['Array'],
    handles => {
        votes       => 'elements',
        votes_count => 'count',
    }
);

has timestamp => (
    isa     => 'DateTime',
    is      => 'ro',
    default => sub { DateTime->now }
);

1;
__END__
