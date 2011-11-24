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
    my $res = $cb->( GET '/register', Accept => 'text/html' );
    for ( $res->content ) {
        like $_, qr|<h1><a href="/">DeepRecursion</a></h1>|;
        like $_, qr|<a href="/login">Login</a>|;
        like $_, qr|<a href="/register">Register</a>|;
        like $_, qr|<form method="POST" action="/users" class="login">|;
        like $_,
            qr|<div class="input" ><label >Username</label><input type="text" name="username" ></div>|;
        like $_,
            qr|<div class="input" ><label >Password</label><input type="password" name="password" ></div>|;
        like $_,
            qr|<div class="input" ><label >Confirm Password</label><input type="password" name="confirm" ></div>|;
        like $_,
            qr|<div class="input" ><input type="submit" name="go" ></div>|;
    }

    # try registering a new user
    $res = $cb->(
        POST '/users',
        [   username => 'ubu',
            password => 'password',
        ]
    );
    is $res->code, '303', 'got the expected code (303)';
    is $res->header('Location'), '/user/user:ubu';
};

done_testing;
