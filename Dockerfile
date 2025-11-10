FROM debian

LABEL maintainer="James Jones <atari@theinnocuous.com>"

COPY . /jaguar-sdk

# Buster was moved to the archives server
RUN echo 'deb http://archive.debian.org/debian buster main' > /etc/apt/sources.list
RUN echo 'deb http://archive.debian.org/debian buster-updates main' >> /etc/apt/sources.list
RUN echo 'deb http://archive.debian.org/debian-security buster/updates main' >> /etc/apt/sources.list

# Need to add stretch repo to get old dosemu package.  It was dropped in buster
RUN echo 'deb http://archive.debian.org/debian stretch contrib' > /etc/apt/sources.list.d/contrib.list

RUN apt-get update && \
	apt-get install -y gawk build-essential gcc-multilib libncurses5-dev libpython3-dev python3-pip wget git libusb-dev dosemu

WORKDIR /jaguar-sdk

RUN ./maketools.sh
RUN ./docker/cleanup_image.sh

RUN echo "\$_cpu_emu = \"full\"" >> ~/.dosemurc
RUN echo "source /jaguar-sdk/env.sh" >> ~/.bashrc
