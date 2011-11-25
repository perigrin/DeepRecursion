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
    ok my $res = $cb->( GET '/register', Accept => 'text/html' ), 'get register page';
    for ( $res->content ) {
        like $_, qr|<h1><a href="/">DeepRecursion</a></h1>|, '... has the DeepRecursion header';
        like $_, qr|<a href="/login">Login</a>|, '... and a login link';
        like $_, qr|<a href="/register">Register</a>|, '... and a register link';
        like $_, qr|<form method="POST" action="/users" class="login">|, '... and a registration form';
        like $_,
            qr|<div class="input" ><label >Username</label><input type="text" name="username" ></div>|, '... with a username field';
        like $_,
            qr|<div class="input" ><label >Password</label><input type="password" name="password" ></div>|, '... and a password field';
        like $_,
            qr|<div class="input" ><label >Confirm Password</label><input type="password" name="confirm" ></div>|, '... and a password confirmation';
        like $_,
            qr|<div class="input" ><input type="submit" name="go" ></div>|, '... and a submit button';
    }

    # try registering a new user
    ok $res = $cb->(
        POST '/users',
        [   username => 'ubu',
            password => 'password',
        ]
    ), 'post the registration';
    is $res->code, '303', 'got the expected code (303)';
    is $res->header('Location'), 'http://localhost/users/user:ubu';
};

done_testing;
