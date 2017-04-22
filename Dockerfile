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
    libpython3.4-dev \
    libgmp-dev \
    libmemcached-dev \
    make \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN git clone --branch 2015.11.11 --depth 1 https://github.com/stevedekorte/io.git ~/io \
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
