# pyslds-docker

## Run Commands
### Build image
`docker build -t pyslds .`

### Make container first time
`docker run --name pyslds_cont -it pyslds bash`

### Start container
`docker start pyslds_cont`

### Execute the container for development
`docker exec -it pyslds_cont bash`

### Stop after development
`docker stop pyslds_cont`
