use strict;
use warnings;

use Backend::DB::Transform;
use Class::Unload;
use English;
use Error::Pure::Utils qw(clean);
use File::Object;
use Test::MockObject;
use Test::More 'tests' => 16;
use Test::NoWarnings;

# Data directory.
my $data = File::Object->new->up->dir('data');

# Test
my $obj = Backend::DB::Transform->new(
	'data_object_prefix' => 'Data::Foo',
);
eval {
	$obj->db2obj('foo');
};
is($EVAL_ERROR, "Database object must be a 'DBIx::Class::Row' instance.\n",
	"Database object must be a 'DBIx::Class::Row' instance.");
clean();

# Test
$obj = Backend::DB::Transform->new(
	'data_object_prefix' => 'Data::Foo',
);
my $mock_object = Test::MockObject->new;
eval {
	$obj->db2obj($mock_object);
};
is($EVAL_ERROR, "Database object must be a 'DBIx::Class::Row' instance.\n",
	"Database object must be a 'DBIx::Class::Row' instance.");
clean();

# Test
unshift @INC, $data->dir('ex1')->s;
$obj = Backend::DB::Transform->new(
	'data_object_prefix' => 'Data::Foo',
);
$mock_object = Test::MockObject->new;
my $mock_resultsource = Test::MockObject->new;
$mock_resultsource->mock('source_name', sub {
	return 'Person';
});
$mock_object->set_isa('DBIx::Class::Row');
$mock_object->mock('result_source', sub {
	return $mock_resultsource;
});
$mock_object->mock('table', sub {
	return 'person';
});
$mock_object->mock('get_columns', sub {
	return (
		'email' => 'skim@cpan.org',
		'name' => 'Michal Josef Spacek',
		'person_id' => 1,
	);
});
my $ret = $obj->db2obj($mock_object);
isa_ok($ret, 'Data::Foo::Person');
is($ret->email, 'skim@cpan.org', 'Get email (skim@cpan.org).');
is($ret->id, 1, 'Get id (1).');
is($ret->name, 'Michal Josef Spacek', 'Get name (Michal Josef Spacek).');
Class::Unload->unload('Data::Foo::Mapping');
Class::Unload->unload('Data::Foo::Person');
shift @INC;
$data->up;

# Test.
unshift @INC, $data->dir('ex2')->s;
$obj = Backend::DB::Transform->new(
	'data_object_prefix' => 'Data::Foo',
);
$mock_object = Test::MockObject->new;
$mock_resultsource = Test::MockObject->new;
$mock_resultsource->mock('source_name', sub {
	return 'Person';
});
$mock_object->set_isa('DBIx::Class::Row');
$mock_object->mock('result_source', sub {
	return $mock_resultsource;
});
$mock_object->mock('table', sub {
	return 'person';
});
$mock_object->mock('get_columns', sub {
	return (
		'email' => 'skim@cpan.org',
		'name' => 'Michal Josef Spacek',
		'person_id' => 1,
	);
});
$ret = $obj->db2obj($mock_object);
isa_ok($ret, 'Data::Foo::Person');
is($ret->email, 'skim@cpan.org', 'Get email (skim@cpan.org).');
is($ret->id, 1, 'Get id (1).');
is($ret->name, 'Michal Josef Spacek', 'Get name (Michal Josef Spacek).');
Class::Unload->unload('Data::Foo::Mapping');
Class::Unload->unload('Data::Foo::Person');
shift @INC;
$data->up;

# Test
$obj = Backend::DB::Transform->new(
	'data_object_prefix' => 'Data::Foo',
);
$mock_object = Test::MockObject->new;
$mock_resultsource = Test::MockObject->new;
$mock_resultsource->mock('source_name', sub {
	return 'Foo';
});
$mock_object->set_isa('DBIx::Class::Row');
$mock_object->mock('result_source', sub {
	return $mock_resultsource;
});
eval {
	$obj->db2obj($mock_object);
};
is($EVAL_ERROR, "Cannot load data object.\n", "Cannot load data object.");

# Test.
unshift @INC, $data->dir('ex3')->s;
$obj = Backend::DB::Transform->new(
	'data_object_prefix' => 'Data::Foo',
);
$mock_object = Test::MockObject->new;
$mock_resultsource = Test::MockObject->new;
$mock_resultsource->mock('source_name', sub {
	return 'Person';
});
$mock_object->set_isa('DBIx::Class::Row');
$mock_object->mock('result_source', sub {
	return $mock_resultsource;
});
$mock_object->mock('table', sub {
	return 'person';
});
$mock_object->mock('get_columns', sub {
	return (
		'email' => 'skim@cpan.org',
		'name' => 'Michal Josef Spacek',
		'person_id' => 1,
	);
});
$ret = $obj->db2obj($mock_object);
isa_ok($ret, 'Data::Foo::Person');
is($ret->email, 'skim@cpan.org', 'Get email (skim@cpan.org).');
is($ret->id, 1, 'Get id (1).');
is($ret->name, 'MICHAL JOSEF SPACEK', 'Get name (MICHAL JOSEF SPACEK).');
Class::Unload->unload('Data::Foo::Mapping');
Class::Unload->unload('Data::Foo::Person');
shift @INC;
$data->up;
