FROM rocker/binder:3.4.2

# Copy repo into ${HOME}, make user own $HOME
USER root
COPY . ${HOME}
RUN chown -R ${NB_USER} ${HOME}
RUN apt-get -y update && \
    apt-get install --no-install-recommends -y openjdk-8-jre-headless ca-certificates-java && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    

RUN R CMD javareconf
USER ${NB_USER}

## run any install.R script we find
RUN if [ -f install.R ]; then R --quiet -f install.R; fi








