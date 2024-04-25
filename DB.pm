package Backend::DB;

use strict;
use warnings;

use Backend::DB::Transform;
use Class::Utils qw(set_params);
use Error::Pure qw(err);
use Scalar::Util qw(blessed);

our $AUTOLOAD;

our $VERSION = 0.02;

sub AUTOLOAD {
	my ($self, @params) = @_;

	my ($package, $method_name) = $AUTOLOAD =~ /^(.+)::([^:]+)$/;

	if ($self->{'debug'}) {
		print "Compile '$AUTOLOAD' method.\n";
	}

	my $method_code = $self->_autoload($package, $method_name, @params);

	# Add method to symbol table.
	no strict "refs";
	*$method_name = $method_code;
	use strict "refs";

	my $code = sub {
		return $method_code->($self, @params);
	};
	goto &$code;
}

sub DESTROY {
	my $self = shift;

	$self = undef;
}

sub new {
	my ($class, @params) = @_;

	# Create object.
	my $self = bless {}, $class;

	# Data object prefix.
	$self->{'data_object_prefix'} = undef;

	# Debug mode.
	$self->{'debug'} = 0;

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
	if (! blessed($self->{'schema'}) || ! $self->schema->isa('DBIx::Class::Schema')) {
		err "Parameter 'schema' must be a 'DBIx::Class::Schema' object.";
	}

	# Check schema version.
	if (defined $self->{'schema_version'} && ! $self->{'schema'}->isa($self->{'schema_version'})) {
		err "Parameter 'schema' must be '".$self->{'schema_version'}."' instance.";
	}

	return $self;
}

sub schema {
	my $self = shift;

	return $self->{'schema'};
}

sub _autoload {
	my ($self, $package, $method_name, @params) = @_;

	my ($prefix, $table_name, $obj);
	if ($method_name =~ m/^([^_]+)_([\w]+)$/ms) {
		$prefix = $1;
		$table_name = $2;
		if ($table_name =~ m/^(\w+)_obj$/ms) {
			$table_name = $1;
			$obj = 1;
		}
	} else {
		err 'Method name is invalid.',
			'Method name', $method_name,
		;
	}

	# Check table name.
	my $source = $self->_check_source($table_name);
	if (! defined $source) {
		err 'Cannot found table name.',
			'Table name', $table_name,
		;
	}

	my $method_code;
	if ($prefix eq 'count') {
		$method_code = sub {
			my ($self, $cond_hr, $attr_hr) = @_;
			return $self->schema->resultset($source)->search($cond_hr, $attr_hr)->count;
		}
	} elsif ($prefix eq 'delete') {
		$method_code = sub {
			my ($self, $cond_hr, $attr_hr) = @_;
			my $row = $self->schema->resultset($source)->search($cond_hr, $attr_hr)->single;
			$row->delete;
			return $row;
		};
	} elsif ($prefix eq 'fetch') {
		if ($obj) {
			$method_code = sub {
				my ($self, $cond_hr, $attr_hr) = @_;
				my $transform = Backend::DB::Transform->new(
					'data_object_prefix' => $self->{'data_object_prefix'},
				);
				my @ret = map { $transform->db2obj($_) }
					$self->schema->resultset($source)->search($cond_hr, $attr_hr);
				return wantarray ? @ret : $ret[0];
			};
		} else {
			$method_code = sub {
				my ($self, $cond_hr, $attr_hr) = @_;
				my @ret = $self->schema->resultset($source)->search($cond_hr, $attr_hr);
				return wantarray ? @ret : $ret[0];
			};
		}
	} elsif ($prefix eq 'save') {
		if ($obj) {
			$method_code = sub {
				my ($self, $struct_hr) = @_;
				my $transform = Backend::DB::Transform->new(
					'data_object_prefix' => $self->{'data_object_prefix'},
				);
				my $obj_db = $self->schema->resultset($source)->create($struct_hr);
				return $transform->db2obj($obj_db);
			};
		} else {
			$method_code = sub {
				my ($self, $struct_hr) = @_;
				return $self->schema->resultset($source)->create($struct_hr);
			};
		}
	} else {
		err 'Prefix is invalid.',
			'Prefix', $prefix,
		;
	}

	return $method_code;
}

sub _check_source {
	my ($self, $table_name) = @_;

	foreach my $source ($self->schema->sources) {
		if ($self->schema->class($source)->table eq $table_name) {
			return $source;
		}
	}

	return;
}

1;

__END__
