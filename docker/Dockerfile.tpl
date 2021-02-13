FROM stickz007/openseedbox1

# Update ubuntu sources list & add key for the transmission ppa
RUN cd /etc/apt \
	&& echo "deb http://ppa.launchpad.net/transmissionbt/ppa/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) main" >> sources.list \
	&& echo "deb-src http://ppa.launchpad.net/transmissionbt/ppa/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) main" >> sources.list \
	&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A37DA909AE70535824D82620976B5901365C5CA1

# Install transmission-daemon
RUN apt-get -qq update \
	&& apt-get install -qq -y transmission-daemon \
	&& apt-get -y clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Update openseedbox-common (from stickz007/openseedbox1) and clone openseedbox-server
RUN git --work-tree=/src/openseedbox-common --git-dir=/src/openseedbox-common/.git pull \
	&& /play/play deps /src/openseedbox-common --sync \
	&& git clone --depth=1 -q https://github.com/stickz/openseedbox-server /src/openseedbox-server \
	&& /play/play deps /src/openseedbox-server --sync

VOLUME /media/openseedbox

COPY application.conf /src/openseedbox-server/conf/application.conf
COPY nginx.conf /etc/nginx/nginx.conf

WORKDIR /src/openseedbox-server
