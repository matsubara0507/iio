FROM python:latest

ENV HOME /root
WORKDIR $HOME

RUN pip install ipython jupyter

# Io

RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    g++ \
    gcc \
    libyajl-dev \
    libpython3-dev \
    libgmp-dev \
    libmemcached-dev \
    make \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN git clone --recursive https://github.com/IoLanguage/io.git \
    && mkdir -p ~/io/build \
    && cd ~/io/build \
    && cmake .. \
    && make install \
    && rm -fr ~/io

WORKDIR $HOME/iio
ADD . $HOME/iio
RUN cd kernels && jupyter kernelspec install io

EXPOSE 8888

CMD ["jupyter", "notebook", "--no-browser", "--allow-root", "--ip='0.0.0.0'"]
