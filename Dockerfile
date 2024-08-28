ARG IMAGE=intersystemsdc/irishealth-community:2020.3.0.200.0-zpm
ARG IMAGE=intersystemsdc/iris-community:2020.4.0.547.0-zpm
ARG IMAGE=containers.intersystems.com/intersystems/iris:2021.1.0.215.0
ARG IMAGE=intersystemsdc/iris-community
ARG IMAGE=intersystemsdc/iris-community:preview
ARG IMAGE=intersystemsdc/iris-community:latest

FROM $IMAGE

WORKDIR /home/irisowner/irisdev

## install git
## USER root   
##RUN apt update && apt-get -y install git
##USER ${ISC_PACKAGE_MGRUSER}

ARG TESTS=0
ARG MODULE="openapi-suite"
ARG NAMESPACE="IRISAPP"

## Embedded Python environment
ENV IRISUSERNAME "_SYSTEM"
ENV IRISPASSWORD "SYS"
ENV IRISNAMESPACE $NAMESPACE
ENV PYTHON_PATH=/usr/irissys/bin/
ENV PATH "/usr/irissys/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/irisowner/bin"

RUN sed -i '/jfrog/d' /etc/apt/sources.list \ 
    && ln -sf /usr/share/zoneinfo/UTC /etc/localtime \ 
    && export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get -y upgrade \
    && apt-get -yq install unattended-upgrades \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN --mount=type=bind,src=.,dst=. \
    iris start IRIS && \
	iris session IRIS < iris.script && \
    ([ $TESTS -eq 0 ] || iris session iris -U $NAMESPACE "##class(%ZPM.PackageManager).Shell(\"test $MODULE -v -only\",1,1)") && \
    iris stop IRIS quietly
