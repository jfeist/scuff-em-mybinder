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
      git

# clone the latest scuff-em version from github, compile and install it, and then
# delete the build directory (again to keep the image small)
RUN cd /tmp && \
    git clone https://github.com/HomerReid/scuff-em.git

RUN /bin/bash -c ". /home/main/anaconda2/bin/activate python3 && conda install -y swig"

RUN /bin/bash -c "cd /tmp/scuff-em && \
    . /home/main/anaconda2/bin/activate python3 && \
    CPPFLAGS='-I/usr/include/hdf5/serial' LDFLAGS='-L/usr/lib/x86_64-linux-gnu/hdf5/serial' ./autogen.sh && \
    make -j 4 install && \
    ldconfig"

# add a "dispatcher" script that can be called as, e.g.,
# "scuff scatter" (which just calls scuff-scatter), and
# which lists the available programs if called without arguments
ADD scuff /usr/local/bin/
RUN chmod +x /usr/local/bin/scuff

USER main

RUN /bin/bash -c ". /home/main/anaconda2/bin/activate python3 && pip install bash_kernel && python -m bash_kernel.install"
RUN cp -r /usr/local/share/scuff-em/examples notebooks
