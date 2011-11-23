#!/usr/bin/env perl 
use Test::More;
use File::Find;

my @classes = ();

my $root = -e 'blib/' ? 'blib/lib' : 'lib';

File::Find::find(
    sub {
        return unless $_ =~ /.pm$/;
        my $path = $File::Find::name;
        $path =~ s|^$root/||;
        $path =~ s|.pm$||;
        $path =~ s|/|::|g;
        push @classes, $path;
    },
    $root
);

ok( scalar(@classes) > 0 );

foreach my $class (@classes) {
    use_ok($class);
}

done_testing( scalar(@classes) + 1 );
