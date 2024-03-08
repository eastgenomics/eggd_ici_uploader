# `dx build` runs `make install` automatically when building an app.
# This Makefile installs ici-uploader in a way that works with DNANexus'
# file mounting approach.
SHELL := /bin/bash

install:
	# install openjdk
	dpkg -i /*.deb

    # make hidden .illumina directory in $HOME and unpack
    # the utilities there because the uploader needs to be
	# that way to work
    mkdir -p /home/dnanexus/.illumina/ici-uploader/
    tar -xvzf /ici-uploader-bundle_linux_x86_64.tar.gz \
    	-C /home/dnanexus/.illumina/ici-uploader/ 
    
    # make PATH-accessible bin/ directory to put the uploader binary in;
    # it'll refer to the $HOME/.illumina directory files by itself
  	mkdir -p /usr/local/bin/
    cp /home/dnanexus/.illumina/ici-uploader/ici-uploader /usr/local/bin/

uninstall:
	# This is for cleaning things up when developing locally
    rm -rf resources/usr resources/home
