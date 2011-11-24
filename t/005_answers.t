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

my %question = (
    title => 'Does this test make me look fat?',
    text  => qq[Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed
    do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad
    minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex
    ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate
    velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat
    cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id
    est laborum.],
);

my %answer = (
    text => qq[Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed
    do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad
    minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex
    ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate
    velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat
    cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id
    est laborum.],
);

test_psgi $app => sub {
    my $cb = shift;

    my $res;

    # Create the User and Login
    $res = $cb->( POST '/users', [%user] );
    $res = $cb->( POST '/login', [%user] );
    my $cookie = $res->header('Set-Cookie');

    # Create the question
    $res = $cb->( POST '/questions', [%question], Cookie => $cookie, );

    # Create an Answer
    my $q_url = $res->header('Location');

    ok $res = $cb->( POST "$q_url/answers", [%answer], Cookie => $cookie ),
        'posted an answer';
    is $res->code, 303, 'got the expected response code (303)';
    is $res->header('Location'), $q_url, 'got the expected re-direct';
    ok $res = $cb->( GET $q_url, Cookie => $cookie, Accept => 'text/html' ),
        'got the question page again';
    is $res->code, 200, 'got the expected status (200)';
    for ( $res->content ) {
        like $_, qr|\Q<h2>$question{title}</h2>\E|, 'got the right title';
        like $_, qr|<div class="text"><p>$question{text}|,
            'got the right question';
        like $_, qr|<div class="text"><p>$answer{text}|,
            'got the right answer';
        like $_, qr|<p>Posted by $user{username} on|, 'got the right user';
    }
};

done_testing;
