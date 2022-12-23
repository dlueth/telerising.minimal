FROM python:3.10-slim-bullseye as base

ENV APT_DEPENDENCIES="build-essential ccache libfuse-dev patchelf upx scons" \
    PIP_DEPENDENCIES="nuitka ordered-set pipreqs" \
    DEBIAN_FRONTEND="noninteractive" \
    TERM=xterm

RUN \
    ### tweak some apt & dpkg settings
    echo "APT::Install-Recommends "0";" >> /etc/apt/apt.conf.d/docker-noinstall-recommends \
    && echo "APT::Install-Suggests "0";" >> /etc/apt/apt.conf.d/docker-noinstall-suggests \
    && echo "Dir::Cache "";" >> /etc/apt/apt.conf.d/docker-nocache \
    && echo "Dir::Cache::archives "";" >> /etc/apt/apt.conf.d/docker-nocache \
    && echo "path-exclude=/usr/share/locale/*" >> /etc/dpkg/dpkg.cfg.d/docker-nolocales \
    && echo "path-exclude=/usr/share/man/*" >> /etc/dpkg/dpkg.cfg.d/docker-noman \
    && echo "path-exclude=/usr/share/doc/*" >> /etc/dpkg/dpkg.cfg.d/docker-nodoc \
    && echo "path-include=/usr/share/doc/*/copyright" >> /etc/dpkg/dpkg.cfg.d/docker-nodoc \
    ### install apt packages
    && apt-get -qy update \
    && apt-get install -qy ${APT_DEPENDENCIES} \
    ### setup python 3
    && python3 -m ensurepip \
    && python3 -m pip install --no-cache --upgrade ${PIP_DEPENDENCIES}

FROM base as builder

ARG TARGETARCH
ARG TAR="false"
ENV WORKDIR=/var/app
WORKDIR ${WORKDIR}
COPY telerising ${WORKDIR}/
COPY root /

RUN mv run.py telerising.py \
    && pipreqs ./ \
    && python3 -m pip install --no-cache --upgrade -r requirements.txt

RUN python3 -OO -m nuitka \
    --standalone \
    --follow-stdlib \
    --prefer-source-code \
    --python-flag=-S,-OO \
    --plugin-enable=anti-bloat,implicit-imports,data-files,pylint-warnings \
    --include-data-dir=./app/static=app/static \
    --include-data-dir=./app/templates=app/templates \
    --warn-implicit-exceptions \
    --warn-unusual-code \
    ./telerising.py

RUN cd telerising.dist/ \
    && /usr/local/sbin/processLibs

RUN cd telerising.dist/ \
    && strip --strip-unneeded --strip-debug telerising \
    && upx --best --overlay=strip telerising

RUN cd /var/dist \
    && cp -r ${WORKDIR}/telerising.dist/* ./

RUN cd /var/dist \
    && /usr/local/sbin/processBin


FROM scratch

COPY --from=builder /var/dist/ /

ENTRYPOINT [ "/telerising" ]