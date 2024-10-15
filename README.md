# DNAnexus_app_template
This could be used as a starting point when developing new apps for DNAnexus

# How to build docker image

```
# set ICI API key in env
export API_KEY=cat illumina-api-key.txt

# build
docker build --secret id=apikey,env=API_KEY -t eastgenomics/ici_uploader:v0.0.1 .
```
