package DeepRecursion;
use Moose;
use FindBin;

use KiokuDB;
use Bread::Board;
use Plack::Builder;
use Plack::Middleware::Magpie;

has dsn => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has db_user => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has db_pass => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has assets => (
    is      => 'ro',
    isa     => 'Bread::Board::Container',
    lazy    => 1,
    builder => '_build_assets',
);

sub _build_assets {
    my $self = shift;
    return container '' => as {
        service 'kioku_dir' => (
            lifecycle => 'Singleton',
            block     => sub {
                my $s = shift;
                KiokuDB->connect(
                    $self->dsn,
                    user     => $self->db_user,
                    password => $self->db_pass,
                    create   => 1,
                    columns  => [],
                );
            }
        );
    };
}

sub app {
    my $self = shift;
    builder {
        enable "Plack::Middleware::Static",
            path => qr{(?:^/(?:images|js|css)/|\.(?:txt|html|xml|ico)$)},
            root => "$FindBin::Bin/static";
        enable "Magpie",
            assets => $self->assets,
            conf   => "$FindBin::Bin/conf/magpie.xml";
    };
}

1;
__END__
