FROM alpine:3.8 AS builder

# install some build tools
RUN apk add --no-cache gcc make musl-dev lha

# build vbcc compiler for amiga
WORKDIR /vbcc_tools
RUN wget http://server.owl.de/~frank/tags/vbcc0_9fP1.tar.gz -O - | tar -xz && \
    cd vbcc && \
    mkdir bin && \
    yes "" | make TARGET=m68k && \
    mkdir -p /opt/amiga/vbcc && \
    cp -r bin /opt/amiga/vbcc && \
    rm -rf /vbcc_tools

WORKDIR /opt/amiga/vbcc
RUN wget http://server.owl.de/~frank/vbcc/2017-08-14/vbcc_target_m68k-amigaos.lha -O vbcc_target_m68k-amigaos.lha && \
    lha x vbcc_target_m68k-amigaos.lha && \
    rm -rf vbcc_target_m68k-amigaos.lha && \
    cp -r vbcc_target_m68k-amigaos/* . && \
    rm -rf vbcc_target_m68k-amigaos*

WORKDIR /opt/amiga/vbcc
RUN wget http://server.owl.de/~frank/vbcc/2017-08-14/vbcc_target_m68k-kick13.lha -O vbcc_target_m68k-kick13.lha && \
    lha x vbcc_target_m68k-kick13.lha && \
    rm -rf vbcc_target_m68k-kick13.lha && \
    cp -r vbcc_target_m68k-kick13/* . && \
    rm -rf vbcc_target_m68k-kick13*

WORKDIR /opt/amiga/vbcc
RUN wget http://server.owl.de/~frank/vbcc/2017-08-14/vbcc_unix_config.tar.gz -O - | tar -xz

ENV VBCC="/opt/amiga/vbcc"
ENV PATH="${VBCC}/bin:${PATH}"

# build vasm assembler for amiga
WORKDIR /vbcc_tools
RUN wget http://sun.hasenbraten.de/vasm/release/vasm.tar.gz -O - | tar -xz && \
    cd vasm && \
    make CPU=m68k SYNTAX=mot && \
    cp vasmm68k_mot vobjdump $VBCC/bin && \
    rm -rf /vbcc_tools

# build vlink linker for amiga
WORKDIR /vbcc_tools
RUN wget http://sun.hasenbraten.de/vlink/release/vlink.tar.gz -O - | tar -xz && \
    cd vlink && \
    make && \
    cp vlink $VBCC/bin && \
    rm -rf /vbcc_tools
    
# install Amiga NDK
WORKDIR /opt/amiga/sdk/
RUN wget http://www.haage-partner.de/download/AmigaOS/NDK39.lha -O NDK39.lha && \
    lha x NDK39.lha && \
    rm -rf NDK39.lha

FROM alpine:3.8

COPY --from=builder /opt/amiga /opt/amiga
ENV VBCC="/opt/amiga/vbcc"
ENV PATH="${VBCC}/bin:${PATH}"
ENV NDK_INC="/opt/amiga/sdk/NDK_3.9/Include/include_h"


# COPY test.c .

# vc +kick13 -c99 -I$NDK_INC test.c -lamiga -lauto -o test
