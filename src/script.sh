#!/bin/bash
set -e -x -o pipefail

# To report errors specifically:
#   dx-jobutil-report-error "My error message"

main() {

    ## Download all inputs
    dx-download-all-inputs

    ## Inject token into upload config
    TOKEN=$(cat $user_access_token_path)
    sed -i "s/\"apiKey\" : null/\"apiKey\" : $TOKEN/" ~/.illumina/ici-uploader/uploader-config.json

    ## Launch upload
    echo $user_access_token
    echo $run_folder
    echo $workflow

    echo $user_access_token_path
    echo $run_folder_path
    echo $workflow_name

    ## Complete upload
    ### check it's installed
    ici-uploader --help
    ici-uploader analysis upload --help
}
