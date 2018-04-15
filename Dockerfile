
FROM jupyter/r-notebook


LABEL maintainer="Arnim Bleier <arnim.bleier@gmail.com>"

USER root

RUN apt-get -y update && \
    apt-get install --no-install-recommends -y openjdk-8-jre-headless ca-certificates-java && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    

RUN R CMD javareconf

USER $NB_UID

