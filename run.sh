LAB="--env JUPYTER_ENABLE_LAB=yes"
TAG=latest
HOSTPORT=8888

docker run --rm -p $HOSTPORT:8888 $LAB \
	-v "$PWD":/home/jovyan/work \
	--env JUPYTER_TOKEN=x --name io_notebook \
       	kyagrd/iio:$TAG
