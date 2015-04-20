## KBase Module Example Perl Code

This branch of the repo contains an example KBase module written in Perl that demonstrates some new
functionality of https://github.com/kbaseIncubater/module_builder

In the example module, a KBase Interface Description Langauage (KIDL) specification is used
to generate perl service code (as a standard KBase service) and an executable wrapper code 
that can be deployed to some execution engine for queuing/executing long running programs 
asynchrounously.

The generated server code handles synchronous requests itself, and forwards long-running
async tasks to an execution engine in a standard way.  The server code can also report on the
state of the long-running code, and can marshall the output data into the correct data types
expected by the calling code.  Therefore, to a programmer using the Service API, calling a 
long-running job is just as easy as calling any other method from a KBase service.

By generating the executable code wrapper automatically, the authors of KBase services can write
all science-logic code in the same implementation file regardless of where the code will run.

A key feature of the new module_builder is that synchronous and async code can be tested locally 
without actual deployment to a remote job manager or execution engine.  This is demostrated here by 
configuring a running example using Travis-CI (https://travis-ci.org/msneddon/service_test)


### More Details

The specification file is defined in Math.spec, which defines two methods- one
synchronous and the other long-running.

The implementation for both the standard service method and the long-running method in the
standard KBase Perl service implementaiton location- lib/Bio/KBase/Math/MathImpl.pm

There is example code for starting up the server in lib/TestPerlServer.sh

There is example code of a Perl client calling the perl server with synchronous and async
calls in lib/TestMathClient.pl


### Travis-CI Information

There is passing Travis-CI configuration that installs everything necssary to test this KBase
module code.   The Makefiles of this service do not use all of the standard KBase conventions
so that the code can be deployed outside of the dev_container, which is important because it
vastly simplifies automated testing in Travis-CI (e.g. there is no KBase runtime required)

The Travis configuration installs the Perl module dependencies, installs the module_builder code,
sets up a mock execution engine using the module_builder tools, compiles the Math.spec file into
client/server code, starts up a perl service (using plackup since this is a test), and runs some
example code that calls the service showing several examples of usage.  See the .travis.yml file
for details.

Note that this repository includes an encrypted configuration variable that contains the password
of a user account used for tests, which is necessary to so tests will not pass for pull requests.
If you want to run tests locally, you should update lib/TestMathClient.pl appropriately using your
own test or user account.

