from ubuntu:18.04

# install ubuntu packages
RUN apt update && \
    apt install -y --no-install-recommends \
        lhasa curl gcc make libc6-dev \
    && rm -rf /var/lib/apt/lists/*

# build vbcc compiler for amiga
RUN mkdir vbcc_tools && \
    cd vbcc_tools && \
    curl -SL http://server.owl.de/~frank/tags/vbcc0_9fP1.tar.gz | tar -xz && \
    mkdir /vbcc_tools/vbcc/bin && \
    cd /vbcc_tools/vbcc && \
    yes "" | make TARGET=m68k && \
    mkdir -p /opt/amiga/vbcc && \
    cp -r bin /opt/amiga/vbcc && \
    rm -rf /vbcc_tools

RUN cd /opt/amiga/vbcc && \
    curl http://server.owl.de/~frank/vbcc/2017-08-14/vbcc_target_m68k-amigaos.lha -o vbcc_target_m68k-amigaos.lha && \
    lha x vbcc_target_m68k-amigaos.lha && \
    rm -rf vbcc_target_m68k-amigaos.lha && \
    cp -r vbcc_target_m68k-amigaos/* . && \
    rm -rf vbcc_target_m68k-amigaos*

RUN cd /opt/amiga/vbcc && \
    curl http://server.owl.de/~frank/vbcc/2017-08-14/vbcc_target_m68k-kick13.lha -o vbcc_target_m68k-kick13.lha && \
    lha x vbcc_target_m68k-kick13.lha && \
    rm -rf vbcc_target_m68k-kick13.lha && \
    cp -r vbcc_target_m68k-kick13/* . && \
    rm -rf vbcc_target_m68k-kick13*

RUN cd /opt/amiga/vbcc && \
    curl http://server.owl.de/~frank/vbcc/2017-08-14/vbcc_unix_config.tar.gz | tar -xz

ENV VBCC="/opt/amiga/vbcc"
ENV PATH="${VBCC}/bin:${PATH}"

# build vasm assembler for amiga
RUN mkdir vbcc_tools && \
    cd vbcc_tools && \
    curl -SL http://sun.hasenbraten.de/vasm/release/vasm.tar.gz | tar -xz && \
    cd vasm && \
    make CPU=m68k SYNTAX=mot && \
    cp vasmm68k_mot vobjdump $VBCC/bin && \
    rm -rf /vbcc_tools

# build vlink linker for amiga
RUN mkdir vbcc_tools && \
    cd vbcc_tools && \
    curl -SL http://sun.hasenbraten.de/vlink/release/vlink.tar.gz | tar -xz && \
    cd vlink && \
    make && \
    cp vlink $VBCC/bin && \
    rm -rf /vbcc_tools
    
# install Amiga NDK
RUN mkdir -p /opt/amiga/sdk/ && \
    cd /opt/amiga/sdk/ && \
    curl -SL http://www.haage-partner.de/download/AmigaOS/NDK39.lha -o NDK39.lha && \
    lha x NDK39.lha && \
    rm -rf NDK39.lha

ENV NDK_INC="/opt/amiga/sdk/NDK_3.9/Include/include_h"

# COPY test.c .

# vc +kick13 -c99 -I$NDK_INC test.c -lamiga -lauto -o test
