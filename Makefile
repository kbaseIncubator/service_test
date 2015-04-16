

#port is now set in deploy.cfg
SERVICE_PORT = $(shell perl server_scripts/get_deploy_cfg.pm NarrativeMethodStore.port)
SERVICE = math
SERVICE_CAPS = Math
SPEC_FILE = Math.spec
WAR = Math.war
URL = https://kbase.us/services/math

#End of user defined variables

GITCOMMIT := $(shell git rev-parse --short HEAD)
TAGS := $(shell git tag --contains $(GITCOMMIT))

TOP_DIR = $(shell python -c "import os.path as p; print p.abspath('../..')")

TOP_DIR_NAME = $(shell basename $(TOP_DIR))

DIR = $(shell pwd)


compile-kb-module:
	kb-module-builder compile $(SPEC_FILE) \
		--out lib \
		--plclname Bio::KBase::$(SERVICE_CAPS)::$(SERVICE_CAPS)Client \
		--plsrvname Bio::KBase::$(SERVICE_CAPS)::$(SERVICE_CAPS)Server \
		--plimplname Bio::KBase::$(SERVICE_CAPS)::$(SERVICE_CAPS)Impl \
		--plpsginame $(SERVICE_CAPS).psgi \
		--jsclname javascript/$(SERVICE_CAPS)Client \
		--pyclname biokbase.$(SERVICE).$(SERVICE_CAPS)Client;





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
