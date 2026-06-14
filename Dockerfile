# 1. 기반 이미지 설정
FROM rocker/tidyverse:4.4.0

# 2. 시스템 의존성 설치
USER root
RUN apt-get update && apt-get install -y \
    wget \
    git \
    imagemagick \
    libmagick++-dev \
    && rm -rf /var/lib/apt/lists/*

# 3. Miniconda 설치
ENV CONDA_DIR=/opt/conda

RUN wget --quiet \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p ${CONDA_DIR} && \
    rm /tmp/miniconda.sh

# 4. Conda 환경 생성
ENV PATH=${CONDA_DIR}/bin:${PATH}

RUN conda create -n r-reticulate python=3.10 pip -y && \
    conda clean -afy

# Python 패키지 설치
RUN /opt/conda/envs/r-reticulate/bin/python -m pip install --upgrade pip && \
    /opt/conda/envs/r-reticulate/bin/python -m pip install \
    numpy \
    pandas \
    matplotlib \
    scipy \
    statsmodels \
    scikit-learn

# 5. R 패키지 설치
RUN R -e "install.packages( \
    c( \
      'reticulate', \
      'remotes', \
      'IRkernel', \
      'rmarkdown', \
      'knitr', \
      'Lahman', \
      'NHANES', \
      'mosaic', \
      'MASS' \
    ), repos='https://cloud.r-project.org')" && \
    R -e "IRkernel::installspec(user = FALSE)"

# 6. reticulate Python 경로 지정
ENV RETICULATE_PYTHON=/opt/conda/envs/r-reticulate/bin/python

# 7. Binder 사용자 생성
ENV NB_USER=jovyan
ENV NB_UID=1000

RUN usermod -l ${NB_USER} rstudio && \
    usermod -d /home/${NB_USER} -m ${NB_USER} && \
    chown -R ${NB_USER} /opt/conda /home/${NB_USER}

# 8. 노트북 복사
COPY hw03.ipynb /home/${NB_USER}/hw03.ipynb

RUN chown ${NB_USER}:users /home/${NB_USER}/hw03.ipynb

USER ${NB_USER}

WORKDIR /home/${NB_USER}

# Binder 포트
EXPOSE 8888
