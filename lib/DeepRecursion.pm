package DeepRecursion;
use Dancer ':syntax';

# ABSTRACT: My private dancer girl, my private dancer girl...
use Dancer::Plugin::KiokuDB;
use Dancer::Plugin::Links;

use DeepRecursion::Question;
use DeepRecursion::Answer;

sub get_question {
    DeepRecursion::Question->new(
        title => 'Lorem ipsum dolor?',
        text =>
'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
        answers => [
            DeepRecursion::Answer->new(
                text =>
'Lorem ipsum dolor sit amet, __consectetur__ adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
            )
        ],
    );
}

before sub {
    if ( session->{user} ) {
        links logout => uri_for('/logout');
    }
    else {
        links login    => uri_for('/login');
        links register => uri_for('/register');
    }
};

get '/' => sub {
    template 'index' => { questions => [ map { get_question() } ( 1 .. 5 ) ] };
};

get '/question/:id' => sub {
    template 'question' => { question => get_question() };
};

any [ 'get', 'post' ] => '/logout' => sub {
    session->destroy;
    redirect '/';
};

any [ 'get', 'post' ] => '/login' => sub {
    links login    => uri_for('/login');
    links register => uri_for('/register');
    return template 'login', {} unless request->method() eq 'POST';

    try {
        my $k     = kiokudb();
        my $scope = $k->new_scope;
        my $user  = $k->lookup( 'user:' . params->{username} )
          or die 'Invalid username';
        $user->check_password( params->{password} )
          or die "Invalid password";
        session user => $user;
        redirect params->{next_resource} || '/';
    }
    catch {
        template 'login', { error => $_ };
    }
};

any [ 'get', 'post' ] => '/register' => sub {
    links login    => uri_for('/login');
    links register => uri_for('/register');
    return template 'register', {} unless request->method() eq 'POST';

    try {
        my $k     = kiokudb();
        my $scope = $k->new_scope;

        die 'password mismatch'
          unless params->{password} eq params->{confirm};
        debug "adding ${\params->{username}} => ${\params->{password}}";
        my $user = PerlStarter::User->new(
            id       => params->{username},
            password => crypt_password( params->{password} ),
        );
        $k->store($user);
        session user => $k->lookup( $user->kiokudb_object_id );
        redirect params->{next_resource} || '/';
    }
    catch {
        template 'register', { error => $_ };
    }
};

true;
