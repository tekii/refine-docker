#
# REFINE Dockerfile
#
# 
FROM tekii/debian-server-jre

MAINTAINER Pablo Jorge Eduardo Rodriguez <pr@tekii.com.ar>

LABEL version="__REFINE_VERSION__"

RUN apt-get update && apt-get install -y wget

ENV REFINE_HOME=__REFINE_HOME__ \
    REFINE_VERSION=__REFINE_VERSION__ \
    REFINE_PORT=3333 \
    REFINE_HOST=0.0.0.0 \
    REFINE_MEMORY=2400M \
    JAVA_OPTIONS=-Drefine.headless=true\ -Drefine.data_dir=__REFINE_HOME__

RUN groupadd --gid 2000 refine && \
    useradd --uid 2000 --gid 2000 --home-dir __REFINE_HOME__ \
            --shell /bin/sh --comment "Account for running REFINE" refine

# you must 'chown 2000.2000 .' this directory in the host in order to
# allow the refine user to write in it.
VOLUME __REFINE_HOME__

# IT-200 - check is this chown actually works...
RUN mkdir -p __REFINE_HOME__ && \
    chown -R refine.refine __REFINE_HOME__

COPY __REFINE_ROOT__ /opt/refine/

RUN chown --recursive root.root /opt/refine

EXPOSE 3333

USER refine

ENTRYPOINT ["/opt/refine/refine", ""]
