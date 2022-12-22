use strict;
use warnings;

use Backend::DB::Transform;
use English;
use Error::Pure::Utils qw(clean);
use Test::More 'tests' => 3;
use Test::NoWarnings;

# Test.
my $obj = Backend::DB::Transform->new(
	'data_object_prefix' => 'Data::Foo',
);
isa_ok($obj, 'Backend::DB::Transform');

# Test.
eval {
	Backend::DB::Transform->new;
};
is($EVAL_ERROR, "Parameter 'data_object_prefix' is required.\n",
	"Parameter 'data_object_prefix' is required.");
clean();
