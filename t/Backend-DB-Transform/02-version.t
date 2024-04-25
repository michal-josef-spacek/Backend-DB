use strict;
use warnings;

use Backend::DB::Transform;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Backend::DB::Transform::VERSION, 0.02, 'Version.');
