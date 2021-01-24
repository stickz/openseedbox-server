FROM stickz007/openseedbox1

# Install build tools
RUN apt-get -qq update \
	&& apt-get -qq install -y \
	ca-certificates libcurl4-openssl-dev libssl-dev pkg-config build-essential zlib1g-dev 
	
# Make & Install Libevent
Run cd /var/tmp \
	&& wget https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz \
	&& tar xzf libevent-2.1.12-stable.tar.gz \
	&& cd libevent-2.1.12-stable \
	&& CFLAGS="-O2" ./configure --prefix=/usr --disable-static && make && make install
	
# Make & Install tranmission	
RUN cd /var/tmp \
	&& wget https://github.com/transmission/transmission-releases/raw/master/transmission-3.00.tar.xz \
	&& tar xvf transmission-3.00.tar.xz \
	&& cd transmission-3.00 \
	&& CFLAGS="-O2" ./configure --disable-gtk --disable-nls --disable-cli --disable-mac --enable-daemon \
	&& make && make install

# Clean up after making is done
RUN apt-get -qq purge -y \
	libcurl4-openssl-dev libssl-dev pkg-config build-essential zlib1g-dev \
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
