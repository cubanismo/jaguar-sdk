FROM debian

LABEL maintainer="James Jones <atari@theinnocuous.com>"

COPY . /jaguar-sdk

# Need to add stretch repo to get old dosemu package.  It was dropped in buster
RUN echo 'deb http://deb.debian.org/debian stretch contrib' > /etc/apt/sources.list.d/contrib.list

RUN apt-get update && \
	apt-get install -y wget build-essential libusb-dev dosemu

WORKDIR /jaguar-sdk

RUN ./maketools.sh
RUN ./docker/cleanup_image.sh

RUN echo "\$_cpu_emu = \"full\"" >> ~/.dosemurc
RUN echo "source /jaguar-sdk/env.sh" >> ~/.bashrc
