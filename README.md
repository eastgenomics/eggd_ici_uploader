# DNAnexus_app_template
This could be used as a starting point when developing new apps for DNAnexus

# How to build docker image

```
docker build -t eastgenomics/ici_uploader:v<SEMANTIC_VERSION> .
```

# Where to save docker image after building

```
mkdir -p resources/image
docker save -o resources/image/ici_uploader_v<SEMVER>.tar.gz
```

# How to build dxasset after saving docker image

```
dx build_asset ici_uploader_image/
```
