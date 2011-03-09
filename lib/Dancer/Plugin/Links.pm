package Dancer::Plugin::Links;
use 5.12.1;
use Dancer ':syntax';
use Dancer::Plugin;

my $links;

register links => sub {
    $links = plugin_setting();
    given ( scalar @_ ) {
        when (0) { return $links }
        when (1) {
            die 'Must provide a HashRef to links' unless ref $_[0] eq 'HASH';
            $links = $_[0];
        }
        when (2) { $links->{ $_[0] } = $_[1]; }
    }
};

before_template sub { shift->{'links'} = $links; };

register_plugin;
1;
__END__
