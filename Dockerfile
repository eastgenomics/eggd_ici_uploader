FROM ubuntu:24.10 
WORKDIR /usr/src/
COPY ici-uploader-bundle_linux_x86_64.tar.gz /usr/src/
RUN apt-get update && \
    apt-get install --no-install-recommends default-jre -y && \
    apt-get clean && \
    apt-get autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/\* /tmp/\* /var/tmp/* && \
    tar xvfz ici-uploader-bundle_linux_x86_64.tar.gz && \
    rm ici-uploader-bundle_linux_x86_64.tar.gz && \
    # ici-uploader install returns exit code 1 because it tries to start a daemon process using systemd.
    # Docker doesn't access systemd by design.
    # ici-uploader still installs everything correctly despite the exit code.
    # We're using "|| exit 0" to stop the exit code from breaking docker build.
    (./ici-uploader install || exit 0) && \
    # clean up installation intermediates
    rm ./*

WORKDIR /root/.illumina/ici-uploader
