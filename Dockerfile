# 1. 기반 이미지 설정
FROM rocker/tidyverse:4.4.0

# 2. 시스템 의존성 설치
USER root
RUN apt-get update && apt-get install -y \
    wget \
    git \
    imagemagick \
    libmagick++-dev \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# 3. R 패키지 설치
RUN R -e "install.packages(c('reticulate','remotes','IRkernel','rmarkdown','knitr','Lahman','NHANES','mosaic','MASS'), repos='https://cloud.r-project.org')" && \
    R -e "IRkernel::installspec(user = FALSE)"

# 4. reticulate Python 경로 지정
ENV RETICULATE_PYTHON=/usr/bin/python3

# 5. Binder 사용자 설정
ENV NB_USER=jovyan
ENV NB_UID=1000

RUN usermod -l ${NB_USER} rstudio && \
    usermod -d /home/${NB_USER} -m ${NB_USER}

# 6. 노트북 복사
COPY hw03.ipynb /home/${NB_USER}/hw03.ipynb

RUN chown -R ${NB_USER}:users /home/${NB_USER}

USER ${NB_USER}
WORKDIR /home/${NB_USER}

EXPOSE 8888
