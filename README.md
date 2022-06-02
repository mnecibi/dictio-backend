# Dictio

https://dictio.io


## Build

### DEV
mix deps.get
iex -S mix

### PROD
docker build -t mnecibi/dictio .
docker push

## Start

### DEV
docker container run -d --name dictio -v $(pwd):/opt/app/dictio/files mnecibi/dictio

### PROD
sudo docker container run -d --privileged=true --name dictio -v $(pwd):/opt/app/dictio/files mnecibi/dictio


