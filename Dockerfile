FROM amake/wine:latest as inno
MAINTAINER Aaron Madlon-Kay <aaron@madlon-kay.com>

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends procps xvfb \
    && rm -rf /var/lib/apt/lists/*

# get at least error information from wine
ENV WINEDEBUG -all,err+all

# Run virtual X buffer on this port
ENV DISPLAY :99

COPY opt /opt
RUN chmod +x /opt/bin/*
ENV PATH $PATH:/opt/bin

USER xclient

# Install Inno Setup binaries
RUN curl -SL "https://files.jrsoftware.org/is/6/innosetup-6.1.2.exe" -o is.exe \
    && wine-x11-run wine is.exe /SP- /VERYSILENT /ALLUSERS /SUPPRESSMSGBOXES \
    && rm is.exe

# Install unofficial languages
RUN cd "/home/xclient/.wine/drive_c/Program Files/Inno Setup 6/Languages" \
    && curl -L "https://api.github.com/repos/jrsoftware/issrc/tarball/is-6_1_2" \
    | tar xz --strip-components=4 --wildcards "*/Files/Languages/Unofficial/*.isl"

FROM debian:buster-slim

RUN addgroup --system xusers \
    && adduser \
    --home /home/xclient \
    --disabled-password \
    --shell /bin/bash \
    --gecos "user for running an xclient application" \
    --ingroup xusers \
    --quiet \
    xclient

# Install some tools required for creating the image
# Install wine and related packages
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    wine \
    wine32 \
    osslsigncode \
    openssl \
    && rm -rf /var/lib/apt/lists/*

COPY opt /opt
RUN chmod +x /opt/bin/*
ENV PATH $PATH:/opt/bin

COPY --chown=xclient:xusers --from=inno /home/xclient/.wine /home/xclient/.wine
RUN mkdir /work && chown xclient:xusers -R /work

ENV CERT_FILE=/sign/certificate.pfx
ENV EXE_FILE=app.exe
ENV EXE_SIGNED=app_signed.exe
ENV PASSWORD=like
ENV TIMESTAMP=http://timestamp.digicert.com
ENV OUTPUT_SIGNED=setup-signed.exe

COPY --from=likesistemas/exe-sign:latest /usr/local/bin/sign /usr/local/bin/sign
COPY --from=likesistemas/exe-sign:latest /work/certificate.pfx /sign/
RUN chmod +x /usr/local/bin/sign

# Wine really doesn't like to be run as root, so let's use a non-root user
USER xclient
ENV HOME /home/xclient
ENV WINEPREFIX /home/xclient/.wine
ENV WINEARCH win32

WORKDIR /work
ENTRYPOINT ["iscc"]
