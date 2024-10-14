#!/bin/bash
set -e -x -o pipefail

# To report errors specifically:
#   dx-jobutil-report-error "My error message"

main() {

    ## Download all inputs
    dx-download-all-inputs

    ## Launch upload
    /home/.illumina/ici-uploader/ici-uploader analysis upload --help
}
