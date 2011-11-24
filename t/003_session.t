#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Plack::Test;
use HTTP::Request::Common;

use DeepRecursion;

my $app = DeepRecursion->new(
    kioku_user => '',
    kioku_pass => '',
    kioku_dsn  => 'dbi:SQLite::memory:',
)->app;

my %user = (
    username => 'perigrin',
    password => 'password',
);

test_psgi $app => sub {
    my $cb = shift;

    # Create the User
    my $res = $cb->( POST '/users', [%user] );

    # Check Login Form
    $res = $cb->( GET '/login', Accept => 'text/html' );
    for ( $res->content ) {
        like $_, qr|<h1><a href="/">DeepRecursion</a></h1>|,
            '/login has a DeepRecursion header';
        like $_,
            qr|<div class="input"><label>Username</label><input type="text" name="username"></div>|,
            '...and a field for username';
        like $_,
            qr|<div class="input"><label>Password</label><input type="password" name="password"></div>|,
            '...and a field for password';
        like $_, qr|<div class="input"><input type="submit" name="go"></div>|,
            '...and a submit button';
    }

    # Create Session
    $res = $cb->( POST '/login', [%user] );
    is $res->code, '303', 'got the expected code (303)';
    like $res->header('Location'), qr|/session/[\w]+|,
        'response location looks correct';

    # Get the Session Resource
    my $location = $res->header('Location');
    my $cookie   = $res->header('Set-Cookie');
    $res = $cb->( GET $location, Cookie => $cookie );
    is $res->code, 302, 'got the expected code (302)';
    like $res->header('Location'), qr|/|, 'response location looks correct';

    # Get the new location
    $location = $res->header('Location');
    $cookie   = $res->header('Set-Cookie');
    $res = $cb->( GET $location, Cookie => $cookie, Accept => 'text/html' );
    is $res->code, 200, 'got the expected code (200)';
    for ( $res->content ) {
        like $_, qr|<h1><a href="/">DeepRecursion</a></h1>|,
            "$location has DeepRecursion header";
        like $_, qr|\Q<li><a href="/login?logout=1">Logout</a></li>\E|,
            '...and a logout link';
        like $_, qr|<h2>Hey there $user{username}!</h2>|, '...and the greeting';
        like $_, qr|<a href="/new_question">ask a question</a>|,
            '...and a link to ask a question';
    }

};

done_testing;
