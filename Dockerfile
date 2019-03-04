# Run Chrome in a container
#
# docker run -it \
#	--net host \ # may as well YOLO
#	--cpuset-cpus 0 \ # control the cpu
#	--memory 512mb \ # max memory it can use
#	-v /tmp/.X11-unix:/tmp/.X11-unix \ # mount the X11 socket
#	-e DISPLAY=unix$DISPLAY \
#	-v $HOME/Downloads:/home/chrome/Downloads \
#	-v $HOME/.config/google-chrome/:/data \ # if you want to save state
#	--security-opt seccomp=$HOME/chrome.json \
#	--device /dev/snd \ # so we have sound
#   --device /dev/dri \
#	-v /dev/shm:/dev/shm \
#	--name chrome \
#	jess/chrome
#
# You will want the custom seccomp profile:
# 	wget https://raw.githubusercontent.com/jfrazelle/dotfiles/master/etc/docker/seccomp/chrome.json -O ~/chrome.json

# Base docker image
#FROM debian:sid-slim
FROM ubuntu:18.04

LABEL maintainer "Jessie Frazelle <jess@linux.com>"

# Install Chrome
RUN apt-get update && apt-get install -y \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg \
	hicolor-icon-theme \
	libcanberra-gtk* \
	libgl1-mesa-dri \
	libgl1-mesa-glx \
	libpango1.0-0 \
	libpulse0 \
	libv4l-0 \
	fonts-symbola \
	--no-install-recommends \
	&& curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
	&& echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
	&& apt-get update && apt-get install -y \
	google-chrome-stable \
	--no-install-recommends \
	&& apt-get purge --auto-remove -y curl \
	&& rm -rf /var/lib/apt/lists/*

# Download the google-talkplugin
RUN set -x \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
	&& rm -rf /var/lib/apt/lists/* \
	&& curl -sSL "https://dl.google.com/linux/direct/google-talkplugin_current_amd64.deb" -o /tmp/google-talkplugin-amd64.deb \
	&& dpkg -i /tmp/google-talkplugin-amd64.deb \
	&& rm -rf /tmp/*.deb \
	&& apt-get purge -y --auto-remove curl

# Add chrome user "wj"
RUN groupadd -r wj && useradd -r -g wj -G audio,video wj \
    && mkdir -p /home/wj/Downloads && chown -R wj:wj /home/wj

#COPY local.conf /etc/fonts/local.conf

# Run Chrome as non privileged user wj
USER wj

# Autorun chrome
ENTRYPOINT [ "google-chrome" ]
CMD [ "--user-data-dir=/data" ]


