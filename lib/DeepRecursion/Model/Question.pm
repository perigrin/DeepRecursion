package DeepRecursion::Model::Question;
use Moose;
use Digest::SHA qw(sha1_hex);
use DateTime;

with qw(KiokuDB::Role::ID);

sub kiokudb_object_id { shift->id }

has id => (
    isa     => 'Str',
    is      => 'ro',
    lazy    => 1,
    default => sub { sha1_hex( $_[0]->title . $_[0]->text ) }
);

has [qw(title text)] => (
    isa      => 'Str',
    is       => 'ro',
    required => 1
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

has answers => (
    isa     => 'ArrayRef[DeepRecursion::Model::Answer]',
    default => sub { [] },
    traits  => ['Array'],
    handles => {
        answers       => 'elements',
        answers_count => 'count',
        add_answer    => 'push',
    }
);

has timestamp => (
    isa     => 'DateTime',
    is      => 'ro',
    default => sub { DateTime->now }
);


1;
__END__
