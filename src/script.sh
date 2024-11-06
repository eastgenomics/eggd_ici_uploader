#!/bin/bash
set -e -x -o pipefail

# To report errors specifically:
#   dx-jobutil-report-error "My error message"

download_run(){
    RUN_PATH=$1
    OUT_FOLDER=$2

    if grep -eq "^project-" <<< $RUN_PATH; then
        dx download -r $RUN_PATH -o $OUT_FOLDER
    else
        dx download -r ${DX_PROJECT_CONTEXT_ID}:${RUN_PATH} -o $OUT_FOLDER
    fi
}

get_match_line_number(){

    FILE=$1
    PATTERN=$2

    local LINE_NUMBER=$(grep -Enow "$PATTERN" $FILE | sed "s/:${PATTERN}//")
    echo $LINE_NUMBER
}

extract_samples(){

    SAMPLESHEET=$1
    PATTERN="Sample_ID"

    local LINE_NUMBER=$(get_match_line_number $SAMPLESHEET $PATTERN)
    local START_AT=$(bc <<< "$LINE_NUMBER + 1")
    tail -n+${START_AT} $SAMPLESHEET | cut -f1 -d,
}

make_case_metadata(){

    SAMPLESHEET=$1

    local SAMPLE_ARRAY=($(extract_samples $SAMPLESHEET))

    echo "Sample_ID,Case_ID,Tumor_Type" > custom_case_metadata.csv

    # the numeric string is the SNOMED ID for "Tumor of Unknown Origin"
    for SAMPLE in ${SAMPLE_ARRAY[@]}; do
        echo "${SAMPLE},${SAMPLE},255051004" >> custom_case_metadata.csv
    done
}

handle_samplesheet() {
    local SAMPLESHEET_PATH=$1
    local SAMPLESHEET_DIRNAME=$(dirname $SAMPLESHEET_PATH)
    local SAMPLESHEET_BASENAME=$(basename $SAMPLESHEET_PATH)
    mv ${SAMPLESHEET_DIRNAME}/${SAMPLESHEET_BASENAME} ${SAMPLESHEET_DIRNAME}/SampleSheet.csv
    echo "$SAMPLESHEET_DIRNAME/SampleSheet.csv"
}

main() {
    # This will download all of the non-run-related inputs (API key, etc.)
    # See next comment for run-related input
    dx-download-all-inputs

    # DNANexus apps don't accept folders as valid arguments, so we can't
    # use dx-download-all-inputs for the run folder. We need to use recursive dx download instead
    download_run $run_folder in/

    # head -n1 returns the first match in the first directory where a samplesheet is found
    ## Potential issue: what happens if there's more than one samplesheet in the topmost directory?
    SAMPLESHEET_PATH=$(find in/ -iname "*SampleSheet*.csv" | head -n1)
    SAMPLESHEET_PATH_UPDATED=$(handle_samplesheet $SAMPLESHEET_PATH)
    make_case_metadata $SAMPLESHEET_PATH_UPDATED
    mv custom_case_metadata.csv in/

    # Start container process in background, and use docker exec to run multiple commands.
    # This is because we need the docker container to persist between steps
    DOCKER_IMAGENAME=$(find /image -name "*.tar.gz")
    sudo docker load -i $DOCKER_IMAGENAME
    DOCKER_IMAGE=$(docker image ls -q)
    docker run \
        --name uploader \
        -e API_KEY_FILENAME=$api_key_file_name \
        -e RUN_FOLDER_NAME=$(basename $run_folder) \
        -e WORKFLOW_ID=$workflow_id \
        --mount type=bind,source=/home/dnanexus/in/,target=/in \
        --entrypoint /bin/bash \
        -itd $DOCKER_IMAGE

    if [ $dry_run == true ]; then
        echo -e "#-----------\n\tPRINTING CUSTOM CASE DATA\n#-----------"
        docker exec uploader bash -c 'cat /in/custom_case_metadata.csv'
        echo -e "\n#-----------\n\tCONTENTS OF /in\n#-----------"
        docker exec uploader bash -c 'ls /in/'
        echo -e "\n#-----------\n\tCONTENTS OF /in/*\n#-----------"
        docker exec uploader bash -c 'ls /in/*'
        exit 0
    else
        # bash -c with single quotes is the only way to use docker container's internal env variables
        # three steps needed - authenticate, upload run, upload case metadata
        docker exec uploader bash -c './ici-uploader configure --api-key $(cat /in/api_key_file/${API_KEY_FILENAME})'
        docker exec uploader bash -c './ici-uploader analysis upload --workflowId $WORKFLOW_ID --folder /in/${RUN_FOLDER_NAME}'
        docker exec uploader bash -c './ici-uploader case-data --filePath /in/custom_case_metadata.csv'
    fi
}
