FROM jupyter/base-notebook

# Io build and install
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    g++ \
    gcc \
    libyajl-dev \
    libpython3-dev \
    libgmp-dev \
    libmemcached-dev \
    make \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN git clone --recursive https://github.com/IoLanguage/io.git \
    && mkdir -p $HOME/io/build \
    && cd $HOME/io/build \
    && cmake .. \
    && make install \
    && rm -rf $HOME/io
RUN    mkdir -p /usr/local/share/jupyter \
    && fix-permissions /usr/local/share/jupyter \
    && mkdir -p /usr/local/share/jupyter/kernels \
    && fix-permissions /usr/local/share/jupyter/kernels

# Jupyter IO kernel install
RUN    mkdir -p /root/iio
COPY iokernel.py /root/iio/iokernel.py
RUN fix-permissions /root

USER $NB_USER
RUN  cd /home/$NB_USER && mkdir -p kernels && mkdir -p kernels/io
COPY kernels/io/kernel.json /home/$NB_USER/kernels/io/kernel.json
RUN  cd /home/$NB_USER/kernels && jupyter kernelspec install io

RUN  cd /home/$NB_USER/ && mkdir -p examples && mkdir -p work
COPY io_example.ipynb /home/$NB_USER/examples/io_example.ipynb

# EXPOSE 8888

# CMD ["jupyter", "notebook", "--no-browser", "--allow-root", "--ip='0.0.0.0'"]
