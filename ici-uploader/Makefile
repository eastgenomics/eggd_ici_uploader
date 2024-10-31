SHELL := /bin/bash -e -x -o pipefail

all:
	apt-get update --yes 
	apt-get install --yes --no-install-recommends default-jre
	cd /src && \
		tar xvzf ici-uploader-bundle_linux_x86_64.tar.gz && \
		cat illumina-api-key.txt | ./ici-uploader install && \
		cd ..
	rm -rf /src
