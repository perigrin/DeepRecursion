package DeepRecursion::Transformer::TT2;
use Moose;
extends qw(Magpie::Transformer::TT2);
use Magpie::Constants;

sub get_tt_conf {
    shift->tt_conf(
        {   
            RELATIVE => 1,
            #DEBUG => 'all'
        }
    );
    return OK;
}

sub get_template {
    my $self = shift;
    my $ctxt = shift;

    return DECLINED if $self->parent_handler->has_error;
    
    $self->response->content_type('text/html');

    ( my $file = $self->request->path_info ) =~ s|^/||;

    unless ($file) {
        $self->template_file('index.tt2');
        return OK;
    }

    my $path = $self->template_path;

    my $template
        = -f "$path/$file.tt2"       ? "$file.tt2"
        : -f "$path/$file/index.tt2" ? "$file/index.tt2"
        :                              "error.tt2";

    $self->template_file($template);
    return OK;
}

1;
__END__
