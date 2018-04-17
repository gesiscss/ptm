# this Dockerfile is created by: repo2docker --debug --no-build binder/. and customized in order to install rJava and openNLP.
FROM buildpack-deps:artful

# Set up locales properly
RUN apt-get update && \
    apt-get install --yes --no-install-recommends locales && \
    apt-get purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Use bash as default shell, rather than sh
ENV SHELL /bin/bash

# Set up user
ARG NB_USER
ARG NB_UID
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}
WORKDIR ${HOME}

RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
       less \
       npm \
       unzip \
       && apt-get purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install --yes \
       libapparmor1 \
       lsb-release \
       psmisc \
       python3 \
       python3-dev \
       python3-venv \
       r-base \
       sudo \
       && apt-get purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
EXPOSE 8888


# Almost all environment variables
ENV APP_BASE /srv
ENV VENV_PATH ${APP_BASE}/venv
ENV NB_PYTHON_PREFIX ${VENV_PATH}
ENV R_LIBS_USER ${APP_BASE}/rlibs
# Special case PATH
ENV PATH ${VENV_PATH}/bin:/usr/lib/rstudio-server/bin/:${PATH}
# If scripts required during build are present, copy them


COPY . ${HOME}
RUN chown -R ${NB_USER}:${NB_USER} ${HOME}
#COPY python/requirements.frozen.txt /tmp/requirements.frozen.txt
RUN mkdir -p ${VENV_PATH} && \
chown -R ${NB_USER}:${NB_USER} ${VENV_PATH}

USER ${NB_USER}
RUN python3 -m venv ${VENV_PATH}

RUN pip install --no-cache-dir -r binder/requirements.frozen.txt && \
jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
jupyter serverextension enable --py jupyterlab --sys-prefix && \
jupyter serverextension enable nteract_on_jupyter --sys-prefix

USER root
RUN mkdir -p ${R_LIBS_USER} && \
chown -R ${NB_USER}:${NB_USER} ${R_LIBS_USER}

RUN curl --silent --location --fail https://download2.rstudio.org/rstudio-server-1.1.419-amd64.deb > /tmp/rstudio.deb && \
echo '24cd11f0405d8372b4168fc9956e0386 /tmp/rstudio.deb' | md5sum -c - && \
dpkg -i /tmp/rstudio.deb && \
rm /tmp/rstudio.deb

RUN sed -i -e '/^R_LIBS_USER=/s/^/#/' /etc/R/Renviron && \
echo "R_LIBS_USER=${R_LIBS_USER}" >> /etc/R/Renviron

USER ${NB_USER}
RUN pip install --no-cache-dir nbrsessionproxy==0.6.1 && \
jupyter serverextension enable nbrsessionproxy --sys-prefix && \
jupyter nbextension install --py nbrsessionproxy --sys-prefix && \
jupyter nbextension enable --py nbrsessionproxy --sys-prefix

RUN R --quiet -e "install.packages('devtools', repos='https://mran.microsoft.com/snapshot/2018-02-01', method='libcurl')" && \
R --quiet -e "devtools::install_github('IRkernel/IRkernel', ref='0.8.11')" && \
R --quiet -e "IRkernel::installspec(prefix='$NB_PYTHON_PREFIX')"

USER root

# Run assemble scripts! These will actually build the specification
# in the repository into the image.
RUN apt-get update && \
apt-get install --yes --no-install-recommends gsl-bin libgsl0-dev default-jre default-jdk && \
apt-get purge && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*

RUN echo "options(repos = c(CRAN='https://mran.microsoft.com/snapshot/2018-04-16'), download.file.method = 'libcurl')" > /etc/R/Rprofile.site

RUN R CMD javareconf
RUN apt-get update && \
apt-get install --yes --no-install-recommends r-cran-rjava && \
apt-get purge && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*

USER ${NB_USER}

#RUN R --quiet -f binder/install.R
RUN Rscript binder/install.R

# We always want containers to run as non-root
USER ${NB_USER}

# Specify the default command to run
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]









