package Bio::KBase::Math::MathClient;

use JSON::RPC::Client;
use POSIX;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
use Time::HiRes;
my $get_time = sub { time, 0 };
eval {
    require Time::HiRes;
    $get_time = sub { Time::HiRes::gettimeofday() };
};

use Bio::KBase::AuthToken;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

Bio::KBase::Math::MathClient

=head1 DESCRIPTION





=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => Bio::KBase::Math::MathClient::RpcClient->new,
	url => $url,
	headers => [],
    };
    my %arg_hash = @args;
    my $async_job_check_time = 5.0;
    if (exists $arg_hash{"async_job_check_time_ms"}) {
        $async_job_check_time = $arg_hash{"async_job_check_time_ms"} / 1000.0;
    }
    $self->{async_job_check_time} = $async_job_check_time;

    chomp($self->{hostname} = `hostname`);
    $self->{hostname} ||= 'unknown-host';

    #
    # Set up for propagating KBRPC_TAG and KBRPC_METADATA environment variables through
    # to invoked services. If these values are not set, we create a new tag
    # and a metadata field with basic information about the invoking script.
    #
    if ($ENV{KBRPC_TAG})
    {
	$self->{kbrpc_tag} = $ENV{KBRPC_TAG};
    }
    else
    {
	my ($t, $us) = &$get_time();
	$us = sprintf("%06d", $us);
	my $ts = strftime("%Y-%m-%dT%H:%M:%S.${us}Z", gmtime $t);
	$self->{kbrpc_tag} = "C:$0:$self->{hostname}:$$:$ts";
    }
    push(@{$self->{headers}}, 'Kbrpc-Tag', $self->{kbrpc_tag});

    if ($ENV{KBRPC_METADATA})
    {
	$self->{kbrpc_metadata} = $ENV{KBRPC_METADATA};
	push(@{$self->{headers}}, 'Kbrpc-Metadata', $self->{kbrpc_metadata});
    }

    if ($ENV{KBRPC_ERROR_DEST})
    {
	$self->{kbrpc_error_dest} = $ENV{KBRPC_ERROR_DEST};
	push(@{$self->{headers}}, 'Kbrpc-Errordest', $self->{kbrpc_error_dest});
    }

    #
    # This module requires authentication.
    #
    # We create an auth token, passing through the arguments that we were (hopefully) given.

    {
	my $token = Bio::KBase::AuthToken->new(@args);
	
	if (!$token->error_message)
	{
	    $self->{token} = $token->token;
	    $self->{client}->{token} = $token->token;
	}
    }

    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




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
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 2)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function add (received $n, expecting 2)");
    }
    {
	my($a, $b) = @args;

	my @_bad_arguments;
        (ref($a) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"a\" (value was \"$a\")");
        (ref($b) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"b\" (value was \"$b\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to add:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'add');
	}
    }

    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
	method => "Math.add",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'add',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method add",
					    status_line => $self->{client}->status_line,
					    method_name => 'add',
				       );
    }
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
    my($self, @args) = @_;
    my $job_id = $self->bigAdd_async(@args);
    while (1) {
        Time::HiRes::sleep($self->{async_job_check_time});
        my $job_state_ref = $self->bigAdd_check($job_id);
        if ($job_state_ref->{"finished"} != 0) {
            if (!exists $job_state_ref->{"result"}) {
                $job_state_ref->{"result"} = [];
            }
            return wantarray ? @{$job_state_ref->{"result"}} : $job_state_ref->{"result"}->[0];
        }
    }
}

sub bigAdd_async {
    my($self, @args) = @_;
# Authentication: required
    if ((my $n = @args) != 2) {
        Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
                                   "Invalid argument count for function bigAdd_async (received $n, expecting 2)");
    }
    {
        my($a, $b) = @args;
        my @_bad_arguments;
        (ref($a) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"a\" (value was \"$a\")");
        (ref($b) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"b\" (value was \"$b\")");
        if (@_bad_arguments) {
            my $msg = "Invalid arguments passed to bigAdd_async:\n" . join("", map { "\t$_\n" } @_bad_arguments);
            Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                   method_name => 'bigAdd_async');
        }
    }
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "Math.bigAdd_async",
        params => \@args});
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
                           code => $result->content->{error}->{code},
                           method_name => 'bigAdd_async',
                           data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
            );
        } else {
            return $result->result->[0];  # job_id
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method bigAdd_async",
                        status_line => $self->{client}->status_line,
                        method_name => 'bigAdd_async');
    }
}

sub bigAdd_check {
    my($self, @args) = @_;
# Authentication: required
    if ((my $n = @args) != 1) {
        Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
                                   "Invalid argument count for function bigAdd_check (received $n, expecting 1)");
    }
    {
        my($job_id) = @args;
        my @_bad_arguments;
        (!ref($job_id)) or push(@_bad_arguments, "Invalid type for argument 0 \"job_id\" (it should be a string)");
        if (@_bad_arguments) {
            my $msg = "Invalid arguments passed to bigAdd_check:\n" . join("", map { "\t$_\n" } @_bad_arguments);
            Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
                                   method_name => 'bigAdd_check');
        }
    }
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "Math.bigAdd_check",
        params => \@args});
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
                           code => $result->content->{error}->{code},
                           method_name => 'bigAdd_check',
                           data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
                          );
        } else {
            return $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method bigAdd_check",
                        status_line => $self->{client}->status_line,
                        method_name => 'bigAdd_check');
    }
}
 
  

sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "Math.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'bigAdd',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method bigAdd",
            status_line => $self->{client}->status_line,
            method_name => 'bigAdd',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for Bio::KBase::Math::MathClient\n";
    }
    if ($sMajor == 0) {
        warn "Bio::KBase::Math::MathClient version is $svr_version. API subject to change.\n";
    }
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

package Bio::KBase::Math::MathClient::RpcClient;
use base 'JSON::RPC::Client';
use POSIX;
use strict;

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $headers, $obj) = @_;
    my $result;


    {
	if ($uri =~ /\?/) {
	    $result = $self->_get($uri);
	}
	else {
	    Carp::croak "not hashref." unless (ref $obj eq 'HASH');
	    $result = $self->_post($uri, $headers, $obj);
	}

    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $headers, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	@$headers,
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
