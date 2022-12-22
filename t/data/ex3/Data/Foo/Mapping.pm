package Data::Foo::Mapping;

use strict;
use warnings;

sub mapping {
	my $table = shift;

	my $mapping_hr = {
		'person' => {
			'name' => ['name', sub {
				my $input = shift;
				return uc($input);
			}],
			'person_id' => 'id',
		},
	};

	return $mapping_hr->{$table};
}
1;
