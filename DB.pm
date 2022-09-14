package Backend::DB;

use strict;
use warnings;

use Class::Utils qw(set_params);
use Error::Pure qw(err);

our $VERSION = 0.01;

sub new {
	my ($class, @params) = @_;

	# Create object.
	my $self = bless {}, $class;

	# Database schema instance.
	$self->{'schema'} = undef;

	# Database schema version.
	$self->{'schema_version'} = undef;

	# Process parameters.
	set_params($self, @params);

	# Check schema.
	if (! defined $self->{'schema'}) {
		err "Parameter 'schema' is required.";
	}
	if (defined $self->{'schema_version'} && ! $self->{'schema'}->isa($self->{'schema_version'})) {
		err "Parameter 'schema' must be '".$self->{'schema_version'}."' instance.";
	}

	return $self;
}

sub schema {
	my $self = shift;

	return $self->{'schema'};
}

1;

__END__
