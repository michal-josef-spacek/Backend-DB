package Backend::DB::Transform;

use strict;
use warnings;

use Class::Utils qw(set_params);
use English;
use Error::Pure qw(err);
use Scalar::Util qw(blessed);

our $VERSION = 0.01;

sub new {
	my ($class, @params) = @_;

	# Create object.
	my $self = bless {}, $class;

	# Data object prefix.
	$self->{'data_object_prefix'} = undef;

	# Mapping module.
	$self->{'mapping_module'} = 'Mapping';

	# Process parameters.
	set_params($self, @params);

	if (! defined $self->{'data_object_prefix'}) {
		err "Parameter 'data_object_prefix' is required.";
	}

	return $self;
}

sub db2obj {
	my ($self, $db_object) = @_;

	if (! blessed($db_object) || ! $db_object->isa('DBIx::Class::Row')) {
		err "Database object must be a 'DBIx::Class::Row' instance.";
	}

	my $source_name = $db_object->result_source->source_name;

	# Load class.
	my $class = $self->{'data_object_prefix'}.'::'.$source_name;
	eval 'require '.$class;
	if ($EVAL_ERROR) {
		err 'Cannot load data object.',
			'Module name', $class,
			'Error', $EVAL_ERROR,
		;
	}

	# Mappings.
	eval 'require '.$self->{'data_object_prefix'}.'::'.$self->{'mapping_module'};
	my $mapping_hr;
	my $table = $db_object->table;
	if (! $EVAL_ERROR) {
		$mapping_hr = eval $self->{'data_object_prefix'}."::".
			$self->{'mapping_module'}."::mapping('".$table."')";
	}
	if (! defined $mapping_hr) {
		$mapping_hr = {
			$table.'_id' => 'id',
		};
	}

	# Map db object to data object.
	my %columns = $db_object->get_columns;
	my %data_columns = ();
	foreach my $column_name (keys %columns) {
		if (defined $mapping_hr->{$column_name}) {
			my $map = $mapping_hr->{$column_name};
			if (ref $map eq 'ARRAY') {
				$data_columns{$map->[0]} = $map->[1]->($columns{$column_name}, $db_object, $self);
			} else {
				$data_columns{$map} = $columns{$column_name};
			}
		} else {
			$data_columns{$column_name} = $columns{$column_name};
		}
	}

	# Create object.
	my $obj = $class->new(
		%data_columns,
	);

	return $obj;
}

sub obj2db {
	# TODO
}

sub _obj_value {
	my ($self, $key, $obj, $method_ar) = @_;

	if (! defined $key) {
		err 'Bad key.';
	}
	if (! defined $obj) {
		err 'Bad object.',
			'Error', 'Object is not defined.',
		;
	}
	if (! blessed($obj)) {
		err 'Bad object.',
			'Error', 'Object in not a instance.',
		;
	}
	my $value = $obj;
	foreach my $method (@{$method_ar}) {
		$value = $value->$method;
		if (! defined $value) {
			return;
		}
	}

	return ($key => $value);
}

1;

__END__
