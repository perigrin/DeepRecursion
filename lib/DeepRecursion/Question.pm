package DeepRecursion::Question;
use Moose;
use Digest::SHA qw(sha1_hex);

has id => (
    isa     => 'Str',
    is      => 'ro',
    lazy    => 1,
    default => sub { sha1_hex( shift->text ) }
);

has title => (
    isa      => 'Str',
    is       => 'ro',
    required => 1
);

has text => (
    isa      => 'Str',
    is       => 'ro',
    required => 1,
);

has votes => (
    isa     => 'ArrayRef[DeepRecursion::User]',
    default => sub { [] },
    traits  => ['Array'],
    handles => {
        votes       => 'elements',
        votes_count => 'count',
    }
);

# has author => (
#     isa      => 'DeepRecursion::User',
#     is       => 'ro',
#     required => 1,
# );

has answers => (
    isa     => 'ArrayRef[DeepRecursion::Answer]',
    default => sub { [] },
    traits  => ['Array'],
    handles => {
        answers       => 'elements',
        answers_count => 'count',
    }
);

1;
__END__
