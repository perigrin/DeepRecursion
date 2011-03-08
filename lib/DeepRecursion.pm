package DeepRecursion;
use Dancer ':syntax';

# ABSTRACT: My private dancer girl, my private dancer girl...
use Dancer::Plugin::KiokuDB;
use Dancer::Plugin::Links;


get '/' => sub {
    if ( session->{user} ) {
        links logout => uri_for('/logout');
    }
    else {
        links login    => uri_for('/login');
        links register => uri_for('/register');
    }
    template 'index';
};

any [ 'get', 'post' ] => '/logout' => sub {
    session->destroy;
    redirect '/';
};

any [ 'get', 'post' ] => '/login' => sub {
    links login => uri_for('/login');
    return template 'login' unless request->method() eq 'POST';

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
    links register => uri_for('/register');
    return template 'register' unless request->method() eq 'POST';

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
