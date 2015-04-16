use Bio::KBase::Math::MathImpl;

use Bio::KBase::Math::MathServer;
use Plack::Middleware::CrossOrigin;



my @dispatch;

{
    my $obj = Bio::KBase::Math::MathImpl->new;
    push(@dispatch, 'Math' => $obj);
}


my $server = Bio::KBase::Math::MathServer->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler = Plack::Middleware::CrossOrigin->wrap( $handler, origins => "*", headers => "*");
