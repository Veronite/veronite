# The Veronite Project - Compiling instructions

Copyright (c) 2018, The Veronite Project

## Development Resources

- Web: [https://veronite.space](https://veronite.space)
- Repo: [https://github.com/veronite/veronite.git](https://github.com/veronite/veronite.git)

## Compiling Veronite from Source

### Dependencies

The following table summarizes the tools and libraries required to build.  A
few of the libraries are also included in this repository (marked as
"Vendored"). By default, the build uses the library installed on the system,
and ignores the vendored sources. However, if no library is found installed on
the system, then the vendored source will be built and used. The vendored
sources are also used for statically-linked builds because distribution
packages often include only shared library binaries (`.so`) but not static
library archives (`.a`).

| Dep            | Min. Version  | Vendored | Debian/Ubuntu Pkg  | Arch Pkg       | Optional | Purpose        |
| -------------- | ------------- | ---------| ------------------ | -------------- | -------- | -------------- |
| GCC            | 4.7.3         | NO       | `build-essential`  | `base-devel`   | NO       |                |
| CMake          | 3.2.0         | NO       | `cmake`            | `cmake`        | NO       |                |
| pkg-config     | any           | NO       | `pkg-config`       | `base-devel`   | NO       |                |
| Boost          | 1.58          | NO       | `libboost-all-dev` | `boost`        | NO       |                |
| OpenSSL      	 | basically any | NO       | `libssl-dev`       | `openssl`      | NO       | sha256 sum     |
| BerkeleyDB     | 4.8           | NO       | `libdb{,++}-dev`   | `db`           | NO       |                |
| libevent       | 2.0           | NO       | `libevent-dev`     | `libevent`     | NO       |                |
| libunbound     | 1.4.16        | YES      | `libunbound-dev`   | `unbound`      | NO       |                |
| libminiupnpc   | 2.0           | YES      | `libminiupnpc-dev` | `miniupnpc`    | YES      | NAT punching   |
| libunwind      | any           | NO       | `libunwind8-dev`   | `libunwind`    | YES      | stack traces   |
| ldns           | 1.6.17        | NO       | `libldns-dev`      | `ldns`         | YES      | ?              |
| expat          | 1.1           | NO       | `libexpat1-dev`    | `expat`        | YES      | ?              |
| GTest          | 1.5           | YES      | `libgtest-dev`^    | `gtest`        | YES      | test suite     |
| Doxygen        | any           | NO       | `doxygen`          | `doxygen`      | YES      | documentation  |
| Graphviz       | any           | NO       | `graphviz`         | `graphviz`     | YES      | documentation  |

[^] On Debian/Ubuntu `libgtest-dev` only includes sources and headers. You must
build the library binary manually. This can be done with the following command ```sudo apt-get install libgtest-dev && cd /usr/src/gtest && sudo cmake . && sudo make && sudo mv libg* /usr/lib/ ```

### Build instructions

Veronite uses the CMake build system and a top-level [Makefile](Makefile) that
invokes cmake commands as needed.

#### On Linux and OS X

* Install the dependencies (see the list above)

    \- On Ubuntu 16.04, essential dependencies can be installed with the following command:

    	sudo apt install build-essential cmake pkg-config
		
* Install Boost from source with -fPiC flag:

	    BOOST_VERSION=1_67_0
    	BOOST_VERSION_DOT=1.67.0
    	BOOST_HASH=2684c972994ee57fc5632e03bf044746f6eb45d4920c343937a465fd67a5adba
		curl -s -L -o  boost_${BOOST_VERSION}.tar.bz2 https://dl.bintray.com/boostorg/release/${BOOST_VERSION_DOT}/source/boost_${BOOST_VERSION}.tar.bz2 \
			&& echo "${BOOST_HASH} boost_${BOOST_VERSION}.tar.bz2" | sha256sum -c \
			&& tar -xvf boost_${BOOST_VERSION}.tar.bz2 \
			&& cd boost_${BOOST_VERSION} \
			&& ./bootstrap.sh \
			&& ./b2 --build-type=minimal link=static runtime-link=static --with-chrono --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-system --with-thread --with-locale threading=multi threadapi=pthread cflags="-fPIC" cxxflags="-fPIC" stage
    	BOOST_ROOT /usr/local/boost_${BOOST_VERSION}
	
* Install OpenSSL from source with -fPiC flag:

    	OPENSSL_VERSION=1.0.2n
    	OPENSSL_HASH=370babb75f278c39e0c50e8c4e7493bc0f18db6867478341a832a982fd15a8fe
	    curl -s -O https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
			&& echo "${OPENSSL_HASH} openssl-${OPENSSL_VERSION}.tar.gz" | sha256sum -c \
			&& tar -xzf openssl-${OPENSSL_VERSION}.tar.gz \
			&& cd openssl-${OPENSSL_VERSION} \
			&& ./Configure linux-x86_64 no-shared --static -fPIC \
			&& make build_crypto build_ssl \
			&& make install
	OPENSSL_ROOT_DIR=/usr/local/openssl-${OPENSSL_VERSION}
	
* Install ZMQ from source with -fPiC flag:

    	ZMQ_VERSION=v4.2.5
    	ZMQ_HASH=d062edd8c142384792955796329baf1e5a3377cd
    	git clone https://github.com/zeromq/libzmq.git -b ${ZMQ_VERSION} \
			&& cd libzmq \
			&& test `git rev-parse HEAD` = ${ZMQ_HASH} || exit 1 \
			&& ./autogen.sh \
			&& CFLAGS="-fPIC" CXXFLAGS="-fPIC" ./configure --enable-static --disable-shared \
			&& make \
			&& make install \
			&& ldconfig

* Install zmq.hpp from source:

    	CPPZMQ_VERSION=v4.2.3
    	CPPZMQ_HASH=6aa3ab686e916cb0e62df7fa7d12e0b13ae9fae6
    	set -ex \
			&& git clone https://github.com/zeromq/cppzmq.git -b ${CPPZMQ_VERSION} \
			&& cd cppzmq \
			&& test `git rev-parse HEAD` = ${CPPZMQ_HASH} || exit 1 \
			&& mv *.hpp /usr/local/include
			
* Install Readline from source with -fPiC flag:

    	READLINE_VERSION=7.0
    	READLINE_HASH=750d437185286f40a369e1e4f4764eda932b9459b5ec9a731628393dd3d32334
    	set -ex \
			&& curl -s -O https://ftp.gnu.org/gnu/readline/readline-${READLINE_VERSION}.tar.gz \
			&& echo "${READLINE_HASH}  readline-${READLINE_VERSION}.tar.gz" | sha256sum -c \
			&& tar -xzf readline-${READLINE_VERSION}.tar.gz \
			&& cd readline-${READLINE_VERSION} \
			&& CFLAGS="-fPIC" CXXFLAGS="-fPIC" ./configure \
			&& make \
			&& make install
	
* Install Sodium from source with -fPiC flag:

    	SODIUM_VERSION=1.0.16
    	SODIUM_HASH=675149b9b8b66ff44152553fb3ebf9858128363d
    	set -ex \
			&& git clone https://github.com/jedisct1/libsodium.git -b ${SODIUM_VERSION} \
			&& cd libsodium \
			&& test `git rev-parse HEAD` = ${SODIUM_HASH} || exit 1 \
			&& ./autogen.sh \
			&& CFLAGS="-fPIC" CXXFLAGS="-fPIC" ./configure \
			&& make \
			&& make check \
			&& make install
			
* Build the source code:

    	cd veronite
    	make release-static -j <number of proc cores>