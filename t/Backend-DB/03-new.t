use strict;
use warnings;

use Backend::DB;
use English;
use Error::Pure::Utils qw(clean);
use File::Object;
use Schema::Test;
use Test::MockObject;
use Test::More 'tests' => 5;
use Test::NoWarnings;

# Data directory.
my $data_dir = File::Object->new->up->dir('data');

# Common.
my $schema = Schema::Test->new->schema->connect(
	'dbi:SQLite:dbname='.$data_dir->file('test.db')->s, '', '');;

# Test.
my $obj = Backend::DB->new(
	'schema' => $schema,
);
isa_ok($obj, 'Backend::DB');

# Test.
eval {
	Backend::DB->new;
};
is($EVAL_ERROR, "Parameter 'schema' is required.\n", "Parameter 'schema' is required.");
clean();

# Test.
eval {
	Backend::DB->new(
		'schema' => 'bad',
	);
};
is($EVAL_ERROR, "Parameter 'schema' must be a 'DBIx::Class::Schema' object.\n",
	"Parameter 'schema' must be a 'DBIx::Class::Schema' object.");
clean();

# Test.
eval {
	Backend::DB->new(
		'schema' => Test::MockObject->new,
	);
};
is($EVAL_ERROR, "Parameter 'schema' must be a 'DBIx::Class::Schema' object.\n",
	"Parameter 'schema' must be a 'DBIx::Class::Schema' object.");
clean();
