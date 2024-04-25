use strict;
use warnings;

use Backend::DB;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Backend::DB::VERSION, 0.02, 'Version.');
