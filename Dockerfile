FROM jfeist/scuff-em:scuff_83c5ff2

USER root

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      python3-pip \
      gmsh \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install jupyterlab jupyterhub matplotlib

ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

WORKDIR ${HOME}
RUN cp -r /tmp/scuff-em/doc/docs/examples/* . 
COPY SiC.mie MieScattering
COPY index.ipynb .
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

ENTRYPOINT []
