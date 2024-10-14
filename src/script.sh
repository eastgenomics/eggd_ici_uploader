#!/bin/bash
set -e -x -o pipefail

# To report errors specifically:
#   dx-jobutil-report-error "My error message"

main() {

    ## Download all inputs
    dx-download-all-inputs

    ## load image
    docker load /usr/src/ici_uploader_0.0.1.tar.gz

    ## launch upload
    docker run eastgenomics/ici_uploader:v0.0.1 --workflowId $workflow_id --folder $run_folder
}
