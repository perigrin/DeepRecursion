package DeepRecursion;
use Moose;

# ABSTRACT: A StackOverflow Clone in Magpie

use FindBin;
use KiokuDB;
use Bread::Board;
use Plack::Builder;
use Plack::Middleware::Magpie;

has [qw(kioku_dsn kioku_user kioku_pass)] => (
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
                    $self->kioku_dsn,
                    user     => $self->kioku_user,
                    password => $self->kioku_pass,
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
            root => 'root/static';
        enable "Magpie",
            assets => $self->assets,
            conf   => 'conf/magpie.xml';
    };
}

1;
__END__
