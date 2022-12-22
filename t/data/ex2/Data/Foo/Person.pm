package Data::Foo::Person;

use strict;
use warnings;

use Mo qw(build is);
use Mo::utils qw(check_number check_required);

our $VERSION = 0.01;

has id => (
	is => 'ro',
);

has name => (
	is => 'ro',
);

has email => (
	is => 'ro',
);

sub BUILD {
	my $self = shift;

	# Check id.
	check_number($self, 'id');

	# Check author.
	check_required($self, 'name');

	# Check email.
	check_required($self, 'email');

	return;
}

1;
