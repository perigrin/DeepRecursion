#!/usr/bin/perl

use strict;
use warnings;

use lib 'lib';
use DeepRecursion;

DeepRecursion->new(
    kioku_user => 'deep_recursion',
    kioku_pass => 'deep_recursion',
    kioku_dsn  => 'dbi:SQLite:site.db',
)->app;
