package DeepRecursion;
use Dancer ':syntax';

# ABSTRACT: My private dancer girl, my private dancer girl...
use Try::Tiny;
use KiokuX::User::Util qw(crypt_password);

use Dancer::Plugin::KiokuDB;
use Dancer::Plugin::Links;

use DeepRecursion::User;
use DeepRecursion::Question;
use DeepRecursion::Answer;

before sub {
    if ( session->{user} ) {
        links logout => uri_for('/logout');
    }
    else {
        links login    => uri_for('/login');
        links register => uri_for('/register');
    }
    links new_question => uri_for('/question/new');
};

get '/' => sub {
    my $dir       = kiokudb;
    my $scope     = $dir->new_scope;
    my $questions = $dir->search( { class => 'DeepRecursion::Question' } );
    template 'index' => { questions => $questions };
};

any [ 'get', 'post' ] => '/question/new' => sub {
    return redirect uri_for('/login') unless session->{user};
    return template 'new_question', {} unless request->method() eq 'POST';
    try {
        my $dir      = kiokudb();
        my $scope    = $dir->new_scope;
        my $user     = $dir->lookup( 'user:' . session->{user}->id );
        my $question = DeepRecursion::Question->new(
            author => $user,
            title  => params->{title},
            text   => params->{text},
        );
        $dir->store($question);
        redirect uri_for("/question/${\$question->id}");
    }
    catch {
        debug $_;
        template 'new_question' => { error => $_ };
    }
};

post '/question/:id/answer' => sub {
    return redirect uri_for('/login') unless session->{user};
    my $dir      = kiokudb;
    my $scope    = $dir->new_scope;
    my $question = $dir->lookup( params->{id} );
    my $user     = $dir->lookup( 'user:' . session->{user}->id );

    my $answer = DeepRecursion::Answer->new(
        author => $user,
        text   => params->{text},
    );
    $question->add_answer($answer);
    $dir->store($question);
    redirect uri_for("/question/${\params->{id}}");
};

get '/question/:id' => sub {
    my $dir      = kiokudb;
    my $scope    = $dir->new_scope;
    my $question = $dir->lookup( params->{id} );
    links new_answer => uri_for("/question/${\params->{id}}/answer");
    template 'question' => { question => $question };
};

any [ 'get', 'post' ] => '/logout' => sub {
    session->destroy;
    redirect '/';
};

any [ 'get', 'post' ] => '/login' => sub {
    return template 'login', {} unless request->method() eq 'POST';

    try {
        my $dir   = kiokudb();
        my $scope = $dir->new_scope;
        my $user  = $dir->lookup( 'user:' . params->{username} )
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
    return template 'register', {} unless request->method() eq 'POST';

    try {
        my $dir   = kiokudb();
        my $scope = $dir->new_scope;

        die 'password mismatch'
          unless params->{password} eq params->{confirm};

        my $user = DeepRecursion::User->new(
            id       => params->{username},
            password => crypt_password( params->{password} ),
        );
        $dir->store($user);
        session user => $dir->lookup( $user->kiokudb_object_id );
        redirect uri_for('/');
    }
    catch {
        template 'register', { error => $_ };
    }
};

true;
