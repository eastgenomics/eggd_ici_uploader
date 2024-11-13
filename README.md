# ICI Run Uploader (DNAnexus Platform App)

Dx wrapper to run the ICI uploader and upload runs to Illumina Connected Insights (ICI).
This is the source code for an app that runs on the DNAnexus Platform.

## What does this app do?
This app launches the `ici-uploader` program and uploads a targeted folder of run data

## What are typical use cases for this app?
This app may be executed as standalone or as part of an analysis pipeline.

Input files come from the output of a bioinformatics analysis pipeline.

## What data are required for this app to run?
This app requires:
* A run folder of output data - the contents depend on the workflow configuration defined by the user within ICI
* An ICI workflow ID specific to the workflow targeting your pipeline output - also defined within ICI
* An ICI API key file - a file containing your API key to access ICI programatically

## What does this app output?
* This app outputs nothing to DNANexus, but uploads data to the ICI platform

**How to run this app**:

Note: the run project ID is optional. If provided, the app will search that project for your data.
If not provided, the app will search the project where the app was executed (i.e. your current working project,
if the `--project` was not also provided to `dx run`).

```bash
dx run app-eggd_ici_uploader/1.0.0 \
  -irun_folder="<run project ID>:</path/to/output/folder>" \
  -iworkflow_id="<workflow ID string>" \
  -iapi_key="<API key file>"
```

## Dependencies
The app requires a tar.gz of the Docker image containing the ICI uploader binary. This is bundled with the app as an app asset,
which is linked by `dxapp.json`. Instructions for building the asset are as follows:

#### How to build the docker image

Download the ICI uploader and store it in the repo directory.

```
docker build -t eastgenomics/ici_uploader:v<SEMANTIC_VERSION> .
```

#### Where to save docker image after building

```
mkdir -p ici-uploader-image/resources/image
docker save -o ici-uploader-image/resources/image/ici_uploader_v<SEMVER>.tar.gz
```

#### How to build dxasset after saving docker image

```
dx build_asset ici-uploader-image/
```

#### This app was made by East GLH
