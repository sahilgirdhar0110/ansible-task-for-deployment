FROM anapsix/alpine-java:8u102b14_server-jre_unlimited

MAINTAINER oaknorth-tp@polarising.com

ENV ARTEFACT_NAME account-service
ENV FOLDER_NAME account-service

# from this point on you should not change anything
ENV UID 51002
ENV USERNAME oaknorthaccountservice
ENV USERGROUP oaknorth
ENV HOME /opt/oaknorth/oaknorthaccountservice/${FOLDER_NAME}
ENV JARFILE ${HOME}/app.jar

RUN apk add -U tzdata \
&& cp /usr/share/zoneinfo/Europe/London /etc/localtime \
&& echo "Europe/London" > /etc/timezone \
&& apk del tzdata 
RUN mkdir -p ${HOME}/config ${HOME}/logs


RUN addgroup ${USERGROUP}

RUN adduser -S -D -s /bin/false -h ${HOME} -G ${USERGROUP} ${USERNAME}

COPY target/${ARTEFACT_NAME}-*.jar ${HOME}/app.jar

RUN chmod u+rx ${HOME}/app.jar && \
    chown -R ${USERNAME}:${USERGROUP} ${HOME}

USER ${USERNAME}

VOLUME ${HOME}/config ${HOME}/logs

CMD set -e && \
    cd ${HOME} && \
    java \
    -Dsun.misc.URLClassPath.disableJarChecking=true \
    -Djava.security.egd=file:/dev/./urandom \
    $JAVA_OPTS \
    -jar $JARFILE $@ && \
    exec "$@"
