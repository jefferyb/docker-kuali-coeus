## Kuali Coeus Dockerfile

This repository contains **Dockerfile** of [Kuali Coeus](https://github.com/kuali/kc)'s [automated build](https://registry.hub.docker.com/u/jefferyb/kuali_coeus/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).

### Base Docker Image

* [ubuntu](https://registry.hub.docker.com/_/ubuntu)

### Installation

1. Install [Docker](https://www.docker.com/).

2. Download [automated build](https://registry.hub.docker.com/u/jefferyb/kuali_coeus/) from public [Docker Hub Registry](https://registry.hub.docker.com/): 

    docker pull jefferyb/kuali_coeus

   (alternatively, you can build an image from Dockerfile: 

    docker build -t="jefferyb/kuali_coeus" github.com/jefferyb/https://github.com/jefferyb/docker-kuali-coeus)


### Usage

#### Run `kuali_coeus`

    docker run -d --name kuali_coeus -h EXAMPLE.COM -p 8080:8080 -p 43306:3306 jefferyb/kuali_coeus

#### Connect to Docker container

To get into the docker image, do:

    docker exec -it kuali_coeus bash

