
SERVICE = math
SERVICE_CAPS = Math
#SERVICE_PORT = $(shell perl server_scripts/get_deploy_cfg.pm $(SERVICE_CAPS).port)
SPEC_FILE = Math.spec
URL = https://kbase.us/services/math

#End of user defined variables

GITCOMMIT := $(shell git rev-parse --short HEAD)
TAGS := $(shell git tag --contains $(GITCOMMIT))

TOP_DIR = $(shell python -c "import os.path as p; print p.abspath('../..')")

TOP_DIR_NAME = $(shell basename $(TOP_DIR))

DIR = $(shell pwd)

LIB_DIR = lib

BIN_DIR = bin
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
	mkdir -p $(BIN_DIR)
	echo '#!/bin/bash' > $(BIN_DIR)/$(EXECUTABLE_SCRIPT_NAME)
	echo 'export PERL5LIB=$(DIR)/$(LIB_DIR):$$PATH:$$PERL5LIB' >> $(BIN_DIR)/$(EXECUTABLE_SCRIPT_NAME)
	echo 'perl $(DIR)/$(LIB_DIR)/Bio/KBase/$(SERVICE_CAPS)/$(SERVICE_CAPS)Server.pm $$1 $$2 $$3' >> $(BIN_DIR)/$(EXECUTABLE_SCRIPT_NAME)
	chmod +x $(BIN_DIR)/$(EXECUTABLE_SCRIPT_NAME)
ifeq ($(TOP_DIR_NAME), dev_container)
	cp $(BIN_DIR)/$(EXECUTABLE_SCRIPT_NAME) $(TOP_DIR)/bin/.
endif



#compile-typespec-java:
#	gen_java_types -S -o . -u $(URL) $(SPEC_FILE)
#	rm -f lib/*.jar

#compile-typespec:
#	mkdir -p lib/biokbase/$(SERVICE)
#	touch lib/biokbase/__init__.py # do not include code in biokbase/__init__.py
#	touch lib/biokbase/$(SERVICE)/__init__.py 
#	mkdir -p lib/javascript/$(SERVICE)
#	compile_typespec \
#		--client Bio::KBase::$(SERVICE_CAPS)::Client \
#		--py biokbase.$(SERVICE).client \
#		--js javascript/$(SERVICE_CAPS)/Client \
#		--url $(URL) \
#		$(SPEC_FILE) lib
#	rm -f lib/*Server.p* #should be no perl/py server files in our lib dir
#	rm -f lib/*Impl.p*   #should be no perl/py impl files in our lib dir
