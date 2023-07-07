FROM arm64v8/ubuntu

# Install essentials
RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get install -y libmicrohttpd-dev libjansson-dev \
    libssl-dev libsofia-sip-ua-dev libglib2.0-dev \
    libopus-dev libogg-dev libcurl4-openssl-dev liblua5.3-dev \
    libconfig-dev pkg-config libtool automake

# Install libnice
RUN apt-get install -y python3 python3-pip python3-setuptools python3-wheel
RUN apt-get install -y git sudo

RUN pip3 install meson
RUN pip3 install ninja
RUN git clone https://gitlab.freedesktop.org/libnice/libnice
RUN cd libnice && meson --prefix=/usr build && ninja -C build && sudo ninja -C build install

# Install libsrtp
RUN apt-get install -y wget
RUN wget https://github.com/cisco/libsrtp/archive/v2.2.0.tar.gz
RUN tar xvf v2.2.0.tar.gz
RUN cd libsrtp-2.2.0 && ./configure --prefix=/usr --enable-openssl && make shared_library && sudo make install

# Install cmake
RUN sudo apt install -y cmake

# Install usrsctp
RUN git clone https://github.com/sctplab/usrsctp
RUN cd usrsctp \
    && ./bootstrap \
    && ./configure --prefix=/usr --disable-programs --disable-inet --disable-inet6 && make && sudo make install

# Install libwebsockets \
RUN git clone https://github.com/warmcat/libwebsockets.git
RUN cd libwebsockets && git checkout v4.3-stable \
    && mkdir build && cd build \
    && cmake -DLWS_MAX_SMP=1 -DLWS_WITHOUT_EXTENSIONS=0 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" .. \
    && make && make install

# Install Paho MQTT c client
RUN git clone https://github.com/eclipse/paho.mqtt.c.git
RUN cd paho.mqtt.c && make && sudo make install

# Install Nanomsg
RUN apt-get install -y aptitude
RUN aptitude install -y libnanomsg-dev

# Install Rabbitmq
RUN git clone https://github.com/alanxz/rabbitmq-c
RUN cd rabbitmq-c && git submodule init && git submodule update && mkdir build && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=/usr .. \
    && make && sudo make install

# For documentation, install Doxygen, Graphviz
RUN aptitude install -y doxygen graphviz

# Compile
RUN git clone https://github.com/meetecho/janus-gateway.git
RUN cd janus-gateway && sh autogen.sh && ./configure --prefix=/opt/janus && make && make install && make configs

# Run server
CMD ["/opt/janus/bin/janus"]