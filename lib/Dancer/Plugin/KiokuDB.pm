package Dancer::Plugin::KiokuDB;
use Dancer ':syntax';
use Dancer::Plugin;

use Class::MOP;

register kiokudb => sub {
    my $conf = plugin_setting();
    my $model_class = $conf->{model_class} // 'KiokuX::Model';
    Class::MOP::load_class($model_class);
    $model_class->new(
        dsn        => $conf->{dsn},
        extra_args => { create => 1, }
    );
    
};

register_plugin;
1;
__END__
