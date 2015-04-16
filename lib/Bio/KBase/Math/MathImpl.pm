package Bio::KBase::Math::MathImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = "0.1.0";

=head1 NAME

Math

=head1 DESCRIPTION



=cut

#BEGIN_HEADER
#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR
    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



=head2 add

  $return = $obj->add($a, $b)

=over 4

=item Parameter and return types

=begin html

<pre>
$a is a Math.f_vector
$b is a Math.f_vector
$return is a Math.f_vector
f_vector is a reference to a list where each element is a float

</pre>

=end html

=begin text

$a is a Math.f_vector
$b is a Math.f_vector
$return is a Math.f_vector
f_vector is a reference to a list where each element is a float


=end text



=item Description



=back

=cut

sub add
{
    my $self = shift;
    my($a, $b) = @_;

    my @_bad_arguments;
    (ref($a) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"a\" (value was \"$a\")");
    (ref($b) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"b\" (value was \"$b\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to add:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'add');
    }

    my $ctx = $Bio::KBase::Math::MathServer::CallContext;
    my($return);
    #BEGIN add

    $return = [];

    my $max_length = scalar @{$a} >= scalar @{$b} ? scalar @{$a} : scalar @{$b};
    print $max_length."\n";
    # initialize array slowly
    for(my $k=0; $k<$max_length; $k++) {
        push $return, 0.0;
    }
    # add things up
    for(my $k=0; $k<$max_length; $k++) {
        if($k < scalar @{$a}) {
            $return->[$k] = $a->[$k];
        }
        if($k < scalar @{$b}) {
            $return->[$k] = $return->[$k] + $b->[$k];
        }
    }

    #END add
    my @_bad_returns;
    (ref($return) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to add:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'add');
    }
    return($return);
}




=head2 bigAdd

  $return = $obj->bigAdd($a, $b)

=over 4

=item Parameter and return types

=begin html

<pre>
$a is a Math.f_vector
$b is a Math.f_vector
$return is a Math.f_vector
f_vector is a reference to a list where each element is a float

</pre>

=end html

=begin text

$a is a Math.f_vector
$b is a Math.f_vector
$return is a Math.f_vector
f_vector is a reference to a list where each element is a float


=end text



=item Description



=back

=cut

sub bigAdd
{
    my $self = shift;
    my($a, $b) = @_;

    my @_bad_arguments;
    (ref($a) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"a\" (value was \"$a\")");
    (ref($b) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"b\" (value was \"$b\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to bigAdd:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'bigAdd');
    }

    my $ctx = $Bio::KBase::Math::MathServer::CallContext;
    my($return);
    #BEGIN bigAdd

    $return = [];

    my $max_length = scalar @{$a} >= scalar @{$b} ? scalar @{$a} : scalar @{$b};
    print $max_length."\n";
    # initialize array slowly
    for(my $k=0; $k<$max_length; $k++) {
        push $return, 0.0;
    }
    # add things up
    for(my $k=0; $k<$max_length; $k++) {
        if($k < scalar @{$a}) {
            $return->[$k] = $a->[$k];
        }
        if($k < scalar @{$b}) {
            $return->[$k] = $return->[$k] + $b->[$k];
        }
    }

    #END bigAdd
    my @_bad_returns;
    (ref($return) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to bigAdd:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'bigAdd');
    }
    return($return);
}




=head2 version 

  $return = $obj->version()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a string
</pre>

=end html

=begin text

$return is a string

=end text

=item Description

Return the module version. This is a Semantic Versioning number.

=back

=cut

sub version {
    return $VERSION;
}

=head1 TYPES



=head2 f_vector

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a float
</pre>

=end html

=begin text

a reference to a list where each element is a float

=end text

=back



=head2 f_matrix2

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a Math.f_vector
</pre>

=end html

=begin text

a reference to a list where each element is a Math.f_vector

=end text

=back



=cut

1;
