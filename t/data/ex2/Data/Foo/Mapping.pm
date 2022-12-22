package Data::Foo::Mapping;

use strict;
use warnings;

sub mapping {
	my $table = shift;

	my $mapping_hr = {
		'person' => {
			'person_id' => 'id',
		},
	};

	return $mapping_hr->{$table};
}

1;
