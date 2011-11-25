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
    text =>
        qq[Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do 
eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut
enim ad minim veniam, quis nostrud exercitation ullamco laboris
nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in
reprehenderit in voluptate velit esse cillum dolore eu fugiat
nulla pariatur. Excepteur sint occaecat cupidatat non proident,
sunt in culpa qui officia deserunt mollit anim id est laborum.],
);

test_psgi $app => sub {
    my $cb = shift;

    my $res;

    # Create the User and Login
    $res = $cb->( POST '/users', [%user] );
    $res = $cb->( POST '/sessions', [%user] );
    my $cookie = $res->header('Set-Cookie');

    ok $res = $cb->( POST '/questions', [%question], Cookie => $cookie, ),
        'posted a question';
    is $res->code, 303, 'got the expected return code (303)';
    like $res->header('Location'), qr|^http://localhost/questions/\w+|,
        '...and the Location header looks right';

    my $url = $res->header('Location');

    ok $res = $cb->( GET $url, Cookie => $cookie, Accept => 'text/html' ),
        'get the new resource';
    is $res->code, 200, 'got the expected return code (200)';
    for ( $res->content ) {
        like $_, qr|\Q<h2>$question{title}</h2>\E|, 'got the right title';
        like $_, qr|<div class="text"><p>$question{text}|,
            'got the right text';
        like $_, qr|<p>Add another answer.</p>|,
            'got a form to add an answer (logged in)';
    }

    ok $res = $cb->( GET $url, Accept => 'text/html' ),
        'trying wihtout a cookie';
    is $res->code, 200, 'got the expected return code (200)';
    for ( $res->content ) {
        like $_, qr|\Q<h2>$question{title}</h2>\E|, 'got the right title';
        like $_, qr|<div class="text"><p>$question{text}|,
            'got the right text';
        unlike $_, qr|<p>Add another answer.</p>|,
            'no form to add an answer (logged out)';
    }
};

done_testing;