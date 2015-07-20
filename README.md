## Kuali Coeus MySQL Dockerfile

This repository contains **Dockerfile** of [MySQL](http://dev.mysql.com/) for [Docker](https://www.docker.com/)'s [automated build](https://registry.hub.docker.com/u/jefferyb/kuali_db_mysql/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).

### Base Docker Image

* [ubuntu](https://registry.hub.docker.com/_/ubuntu)

### Installation

1. Install [Docker](https://www.docker.com/).

2. Download [automated build](https://registry.hub.docker.com/u/jefferyb/kuali_db_mysql/) from public [Docker Hub Registry](https://registry.hub.docker.com/): 

    docker pull jefferyb/kuali_db_mysql

   (alternatively, you can build an image from Dockerfile: 

    docker build -t="jefferyb/kuali_db_mysql" github.com/jefferyb/https://github.com/jefferyb/docker-mysql-kuali-coeus)


### Usage

#### Run `kuali_db_mysql`

    docker run -d --name kuali_db_mysql -h kuali_db_mysql -p 43306:3306 jefferyb/kuali_db_mysql

#### Connect to Docker container

To get into the docker image, do:

    docker exec -it kuali_db_mysql bash

