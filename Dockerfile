FROM rocker/tidyverse:4.4.0

USER root

RUN apt-get update && apt-get install -y \
    wget \
    git \
    imagemagick \
    libmagick++-dev \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

ENV RETICULATE_PYTHON=/usr/bin/python3

ENV NB_USER=jovyan
ENV NB_UID=1000

RUN usermod -l ${NB_USER} rstudio && \
    usermod -d /home/${NB_USER} -m ${NB_USER}

COPY hw03.ipynb /home/${NB_USER}/hw03.ipynb

RUN chown -R ${NB_USER}:users /home/${NB_USER}

USER ${NB_USER}
WORKDIR /home/${NB_USER}

EXPOSE 8888
