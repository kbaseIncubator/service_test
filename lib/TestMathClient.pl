
use strict;
use Data::Dumper;
use Bio::KBase::Math::MathClient;


my $user = $ENV{'KB_TEST_USER_NAME'};
my $psswd = $ENV{'TEST_PSWD'};

# Initialize the client
# note: if you are logged in using kbase-login, then you don't need to set user name and password here
my $math = new Bio::KBase::Math::MathClient("http://localhost:5000",user_id=>$user, password=>$psswd);

# standard rpc call
print "Calling RPC \$math->add(..)\n";
my $result = $math->add([1,2,3],[4,5,6]);
print "returned: \n  ".Dumper($result);

# 
print "Calling a long running method in a synchronous way \$math->bigAdd(..)\n";
my $result = $math->bigAdd([1,2,3],[4,5,6]);
print "returned: \n  ".Dumper($result);


print "Submitting a long running method \$math->bigAdd_async(..)\n";
my $job_id = $math->bigAdd_async([1,2,3],[4,5,6]);
print "returned a job_id: $job_id\n";

while(1) {
    my $job_state = $math->bigAdd_check($job_id);
    print "Checking job state: \n  ".Dumper($job_state);
    if ($job_state->{finished} != 0) {
        if (!exists $job_state->{result}) {
            $job_state->{result} = [];
        }
        print "Job Complete, result returned: \n  ".Dumper($job_state->{result}[0]);
        last;
    }
    sleep 1;
}
