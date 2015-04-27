
SERVICE = math
SERVICE_CAPS = Math
# note, service port should really be defined in deploy.cfg, as in:
#$(shell perl server_scripts/get_deploy_cfg.pm $(SERVICE_CAPS).port)
SERVICE_PORT = 5000
SPEC_FILE = Math.spec
URL = https://kbase.us/services/math

#End of user defined variables

GITCOMMIT := $(shell git rev-parse --short HEAD)
TAGS := $(shell git tag --contains $(GITCOMMIT))

TOP_DIR = $(shell python -c "import os.path as p; print p.abspath('../..')")

TOP_DIR_NAME = $(shell basename $(TOP_DIR))

DIR = $(shell pwd)

LIB_DIR = lib

# we have to name this LBIN_DIR (Local Bin Directory) so it doesn't conflict with a KBase common Makefile Variable
# with the same name!
LBIN_DIR = bin
EXECUTABLE_SCRIPT_NAME = run_$(SERVICE_CAPS)_async_job.sh


default: compile-kb-module build-executable-script-perl

compile-kb-module:
	kb-module-builder compile $(SPEC_FILE) \
		--out $(LIB_DIR) \
		--plclname Bio::KBase::$(SERVICE_CAPS)::$(SERVICE_CAPS)Client \
		--plsrvname Bio::KBase::$(SERVICE_CAPS)::$(SERVICE_CAPS)Server \
		--plimplname Bio::KBase::$(SERVICE_CAPS)::$(SERVICE_CAPS)Impl \
		--plpsginame $(SERVICE_CAPS).psgi \
		--jsclname javascript/$(SERVICE_CAPS)Client \
		--pyclname biokbase.$(SERVICE).$(SERVICE_CAPS)Client;

# NOTE: script generation and wrapping in various languages should be
# handled in a kb-module-builder tool, but for now we just generate the
# script within this makefile
build-executable-script-perl:
	mkdir -p $(LBIN_DIR)
	echo '#!/bin/bash' > $(LBIN_DIR)/$(EXECUTABLE_SCRIPT_NAME)
	echo 'export PERL5LIB=$(DIR)/$(LIB_DIR):$$PATH:$$PERL5LIB' >> $(LBIN_DIR)/$(EXECUTABLE_SCRIPT_NAME)
	echo 'perl $(DIR)/$(LIB_DIR)/Bio/KBase/$(SERVICE_CAPS)/$(SERVICE_CAPS)Server.pm $$1 $$2 $$3' >> $(LBIN_DIR)/$(EXECUTABLE_SCRIPT_NAME)
	chmod +x $(LBIN_DIR)/$(EXECUTABLE_SCRIPT_NAME)
ifeq ($(TOP_DIR_NAME), dev_container)
	cp $(LBIN_DIR)/$(EXECUTABLE_SCRIPT_NAME) $(TOP_DIR)/bin/.
endif

clean:
	rm -rfv $(LBIN_DIR)



# below are targets for deploying in a KBase environment - note that these
# are hacked together to get things working for now, and should be refactored if
# this example is going to be copied into a production service
ifeq ($(TOP_DIR_NAME), dev_container)
include $(TOP_DIR)/tools/Makefile.common
include $(TOP_DIR)/tools/Makefile.common.rules

DEPLOY_RUNTIME ?= /kb/runtime
TARGET ?= /kb/deployment
SERVICE_DIR ?= $(TARGET)/services/$(SERVICE)

PID_FILE = $(SERVICE_DIR)/service.pid
ACCESS_LOG_FILE = $(SERVICE_DIR)/access.log
ERR_LOG_FILE = $(SERVICE_DIR)/error.log
WORKERS = 5

deploy: deploy-service

deploy-service: deploy-service-libs deploy-executable-script deploy-service-scripts deploy-cfg

deploy-service-libs:
	@echo "Deploying libs to target: $(TARGET)"
	rsync -vrh lib/* $(TARGET)/lib/. \
		--exclude TestMathClient.pl --exclude TestPerlServer.sh \
		--exclude *.bak* --exclude AuthConstants.pm
	mkdir -p $(SERVICE_DIR)
	echo $(GITCOMMIT) > $(SERVICE_DIR)/$(SERVICE).serverdist
	echo $(TAGS) >> $(SERVICE_DIR)/$(SERVICE).serverdist

deploy-executable-script:
	@echo "Installing executable scripts to target: $(TARGET)/bin"
	echo '#!/bin/bash' > $(TARGET)/bin/$(EXECUTABLE_SCRIPT_NAME)
	echo 'export KB_RUNTIME=$(DEPLOY_RUNTIME)' >> $(TARGET)/bin/$(EXECUTABLE_SCRIPT_NAME)
	echo 'export PATH=$(TARGET)/bin:$(DEPLOY_RUNTIME)/bin:$$PATH' >> $(TARGET)/bin/$(EXECUTABLE_SCRIPT_NAME)
	echo 'export PERL5LIB=$(TARGET)/lib' >> $(TARGET)/bin/$(EXECUTABLE_SCRIPT_NAME)
	echo 'perl $(TARGET)/lib/Bio/KBase/$(SERVICE_CAPS)/$(SERVICE_CAPS)Server.pm $$1 $$2 $$3' >> $(TARGET)/bin/$(EXECUTABLE_SCRIPT_NAME)
	chmod +x $(TARGET)/bin/$(EXECUTABLE_SCRIPT_NAME)

deploy-service-scripts:
	# Note: creating start/stop scripts should migrate to its own utility script, or to a template....
	@echo "Deploying start/stop server scripts to target: $(TARGET)"
	@echo "Server will listen on port: $(SERVICE_PORT)"
	mkdir -p $(SERVICE_DIR)
	# First create the start script (should be a better way to do this...)
	echo '#!/bin/sh' > ./start_service
	echo "echo starting $(SERVICE) service." >> ./start_service
	echo 'export PERL5LIB=$(TARGET)/lib' >> ./start_service
	#NOTE: we have to figure out where and who defines the Deployment Config location!!  It is not
	# in deployment/user-env.sh ... so for this test, we just assume it exists
	echo 'export KB_DEPLOYMENT_CONFIG=$(TARGET)/deployment.cfg'  >> ./start_service 
	echo "$(DEPLOY_RUNTIME)/bin/starman --listen :$(SERVICE_PORT) --pid $(PID_FILE)  --workers $(WORKERS) --daemonize \\" >> ./start_service
	echo "  --access-log $(ACCESS_LOG_FILE) \\" >>./start_service
	echo "  --error-log $(ERR_LOG_FILE) \\" >> ./start_service
	echo "  $(TARGET)/lib/$(SERVICE_CAPS).psgi" >> ./start_service
	echo "echo $(SERVICE_NAME) service is listening on port $(SERVICE_PORT)." >> ./start_service
	# Second create the stop script
	echo '#!/bin/sh' > ./stop_service
	echo "echo trying to stop $(SERVICE) service." >> ./stop_service
	echo "pid_file=$(PID_FILE)" >> ./stop_service
	echo "if [ ! -f \$$pid_file ] ; then " >> ./stop_service
	echo "    echo \"No pid file: \$$pid_file found for service $(SERVICE_NAME).\"" >> ./stop_service
	echo "    exit 1" >> ./stop_service
	echo "fi" >> ./stop_service
	echo "pid=\$$(cat \$$pid_file)" >> ./stop_service
	echo "kill \$$pid" >> ./stop_service
	chmod +x start_service stop_service
	mv start_service $(SERVICE_DIR)/.
	mv stop_service $(SERVICE_DIR)/.

endif
