package DeepRecursion;
use Dancer ':syntax';

# ABSTRACT: My private dancer girl, my private dancer girl...

get '/' => sub {
    template 'index';
};

true;
