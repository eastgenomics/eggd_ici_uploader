#!/bin/bash
set -e -x -o pipefail

# To report errors specifically:
#   dx-jobutil-report-error "My error message"

main() {
    dx-download-all-inputs
    # DNANexus apps don't accept folders as valid arguments, so we can't
    # use dx-download-all-inputs. We need to use recursive dx download instead
    dx download -r ${DX_PROJECT_CONTEXT_ID}:${run_folder} -o in/
    export RUN_FOLDER_NAME=$(basename $run_folder)
    # Start container process in background, and use docker exec to run multiple commands.
    # This is because we need the docker container to persist between steps
    sudo docker load -i /image/ici_uploader_v1.0.0.tar.gz
    docker run \
        --name uploader \
        -e API_KEY_FILENAME=$api_key_file_name \
        -e RUN_FOLDER=$run_folder \
        -e WORKFLOW_ID=$workflow_id \
        --mount type=bind,source=/home/dnanexus/in/,target=/in \
        --entrypoint /bin/bash \
        -itd eastgenomics/ici_uploader:v1.0.0
    # bash -c with single quotes is the only way to use docker container's internal env variables
    # two steps needed - authenticate, then upload
    docker exec uploader bash -c './ici-uploader configure --api-key $(cat /in/api_key_file/${API_KEY_FILENAME})'
    docker exec uploader bash -c './ici-uploader analysis upload --workflowId $WORKFLOW_ID --folder /in/${RUN_FOLDER}'
}
