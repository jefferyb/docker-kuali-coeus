# Kuali Coeus Tomcat Dockerfile

This repository contains the **Dockerfile** of an [ automated build of a Kuali Coeus Bundled image ](https://registry.hub.docker.com/u/jefferyb/kuali_coeus/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).

# How to Use the Kuali Coeus Bundled Images

## Start a Kuali Coeus Bundled Instance

To start a Kuali Coeus Bundled instance as follows:

docker run  -d \
  --name kuali-coeus-bundled \
  -e KUALI_APP_URL=EXAMPLE.COM \
  -e KUALI_APP_URL_PORT=80 \
  -p 80:8080 \
  jefferyb/kuali_coeus

and then access it at http://EXAMPLE.COM/kc-dev

**NOTE:** This image needs at least 2 environment set (unless you're running it on localhost on port 8080):
  * `-e KUALI_APP_URL=EXAMPLE.COM` Where EXAMPLE.COM is the fqdn or IP address where you want to access it
  * `-e KUALI_APP_URL_PORT=80` KUALI_APP_URL_PORT needs to be equal to the PRIVATE_PORT number, the port set using -p.

## Build a Kuali Coeus Bundled Image yourself

You can build an image from the docker-compose.yml file:

    docker-compose build

Alternatively, you can build an image from the Dockerfile:

    docker build  -t jefferyb/kuali_coeus https://github.com/jefferyb/docker-kuali-coeus.git

## Watch the logs

You can check the logs using:

    docker logs -f kuali-coeus-bundled

## Access Kuali Coeus Application

To access the Kuali Coeus instance, go to:

    http://EXAMPLE.COM:8080/kc-dev

Where EXAMPLE.COM is whatever you set `-e KUALI_APP_URL` to,
and port number is whatever you set `-e KUALI_APP_URL_PORT` to.

## Download the XML Files to ingest

To download the Kuali Coeus XML files, go to:

    For rice-xml
      http://EXAMPLE.COM:8080/xml_files/rice-xml.${Kuali-Coeus-Version}.zip

    For coeus-xml
      http://EXAMPLE.COM:8080/xml_files/coeus-xml.${Kuali-Coeus-Version}.zip

Where ${Kuali-Coeus-Version} is the version number on the http://EXAMPLE.COM:8080/kc-dev login page.

For example:
if the current version on the login page says: KualiCo 1607 MySQL
then to get the rice-xml and coeus-xml files, the links would be:

    http://EXAMPLE.COM:8080/xml_files/rice-xml.1607.zip
    http://EXAMPLE.COM:8080/xml_files/coeus-xml.1607.zip

## Container Shell Access

The `docker exec` command allows you to run commands inside a Docker container. The following command line will give you a bash shell inside your Kuali Coeus Bundled container:

    docker exec -it kuali-coeus-bundled bash

# Environment Variables

When you start/build the Kuali Coeus Bundled image, you can adjust the configuration of the Kuali Coeus Bundled instance by passing one or more environment variables on the `docker run` command line or `Dockerfile/docker-compose.yml` file.

Most of the variables listed below are optional, but at least `KUALI_APP_URL`, `KUALI_APP_URL_PORT` need to be there to get started (unless you're running it on localhost on port 8080)...

## `KUALI_APP_URL`
The fqdn or IP address where you want to access your application
Default: KUALI_APP_URL="localhost"

## `KUALI_APP_URL_PORT`
The port number where you want to access your application
Default: KUALI_APP_URL_PORT="8080"

## `MYSQL_HOSTNAME`
The hostname of your MySQL instance. If you're linking dockers, then it will be the container name of your database
Default: MYSQL_HOSTNAME="kuali-coeus-database"

## `MYSQL_PORT`
The MySQL port number
Default: MYSQL_PORT="3306"

## `MYSQL_USER`
The username to use.
Default: MYSQL_USER="kcusername"

## `MYSQL_PASSWORD`
The password for the username.
Default: MYSQL_PASSWORD="kcpassword"

## `MYSQL_DATABASE`
The name of the database.
Default: MYSQL_DATABASE="kualicoeusdb"
