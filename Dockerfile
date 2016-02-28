FROM andrewosh/binder-base

MAINTAINER Johannes Feist <johannes.feist@gmail.com>

USER root

# install the packages necessary to compile scuff-em,
# and clean up as much as possible afterwards to keep the image small
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      build-essential \
      automake \
      libtool \
      flex \
      bison \
      gfortran \
      libreadline-dev \
      libopenblas-dev \
      liblapack-dev \
      libhdf5-dev \
      ca-certificates \
      git \
      gmsh

# clone the latest scuff-em version from github, compile and install it
RUN git clone https://github.com/HomerReid/scuff-em.git /tmp/scuff-em && \
    cd /tmp/scuff-em && \
    CPPFLAGS='-I/usr/include/hdf5/serial' LDFLAGS='-L/usr/lib/x86_64-linux-gnu/hdf5/serial' ./autogen.sh --without-python && \
    make -j 4 install && \
    ldconfig

USER main

RUN cp -r /tmp/scuff-em/doc/docs/examples notebooks
#ADD SiC.mie notebooks/MieScattering
