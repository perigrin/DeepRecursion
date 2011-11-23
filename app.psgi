#!/usr/bin/perl

use strict;
use warnings;

use lib 'lib';
use DeepRecursion;

DeepRecursion->new(
    db_user => 'deep_recursion',
    db_pass => 'deep_recursion',
    dsn     => 'dbi:SQlite:deep_recursion.db',
)->app;
