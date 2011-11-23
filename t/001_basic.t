#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Plack::Test;
use HTTP::Request::Common;

use DeepRecursion;

ok( my $app = DeepRecursion->new(
        kioku_user => '',
        kioku_pass => '',
        kioku_dsn  => 'dbi:SQLite::memory:',
        )->app
);

test_psgi $app => sub {
    my $cb = shift;
    my $res = $cb->( GET '/', Accept => 'text/html' );
    for ( $res->content ) {
        like $_, qr|<h1><a href="/">DeepRecursion</a></h1>|;
        like $_, qr|<a href="/login">Login</a>|;
        like $_, qr|<a href="/register">Register</a>|;
        like $_, qr|<a href="/new_question">ask a question</a>|;
    }
};

done_testing;
