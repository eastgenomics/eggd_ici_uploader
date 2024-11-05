# DNAnexus_app_template
This could be used as a starting point when developing new apps for DNAnexus

# How to build docker image

Download the ICI uploader and store it in the repo directory.

```
docker build -t eastgenomics/ici_uploader:v<SEMANTIC_VERSION> .
```

# Where to save docker image after building

```
mkdir -p ici-uploader-image/resources/image
docker save -o ici-uploader-image/resources/image/ici_uploader_v<SEMVER>.tar.gz
```

# How to build dxasset after saving docker image

```
dx build_asset ici-uploader-image/
```
