#!/usr/bin/env perl

use strict;
use warnings;
use v5.14;

use Test::More tests => 2;

BEGIN { use_ok 'Bake' }

ok('Bake' eq Bake::find_namespace(),'Default Namespace Returned from Find Namespace');
