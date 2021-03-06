#
# REFINE Dockerfile
#
#
FROM tekii/server-jre

MAINTAINER Pablo Jorge Eduardo Rodriguez <pr@tekii.com.ar>

LABEL version=__VERSION__

COPY config.patch __INSTALL__/

RUN apt-get --quiet=2 update && \
    apt-get --quiet=2 install --assume-yes --no-install-recommends wget patch && \
    echo "start downloading and decompressing __LOCATION__/__TARBALL__" && \
    wget -q -O - __LOCATION__/__TARBALL__ | tar -xz --strip=1 -C __INSTALL__ && \
    echo "end downloading and decompressing." && \
    cd __INSTALL__ && patch --strip=1 --input=config.patch && cd - && \
    apt-get purge --assume-yes patch && \
    apt-get --quiet=2 autoremove --assume-yes && \
    apt-get --quiet=2 clean && \
    apt-get --quiet=2 autoclean && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    chown --recursive root:root __INSTALL__

ENV REFINE_HOME=__HOME__ \
    REFINE_VERSION=__VERSION__ \
    REFINE_PORT=3333 \
    REFINE_HOST=0.0.0.0 \
    REFINE_MEMORY=2400M \
    JAVA_OPTIONS=-Drefine.headless=true\ -Drefine.data_dir=__HOME__

# you must 'chown __USER__.__GROUP__ .' this directory in the host in
# order to allow the jira user to write in it.
VOLUME __HOME__

EXPOSE 3333

USER __USER__:__GROUP__

ENTRYPOINT ["__INSTALL__/refine", ""]
