FROM develar/java:8u45

#Version to download:
#https://www.atlassian.com/software/crowd/downloads/binary/atlassian-crowd-2.9.1.tar.gz

ENV CROWD_VERSION=2.10.1
ENV GLIBC_VERSION=2.23-r3
ENV CROWD_HOME=/var/atlassian/application-data/crowd
ENV CROWD_INSTALL=/opt/atlassian/crowd
ENV CROWD_USER=daemon
ENV CROWD_GROUP=daemon
ENV MYSQL_CONNECTOR_VERSION=5.1.39

RUN apk --update upgrade && \
  apk --update add curl ca-certificates gzip tar && \
  mkdir -p ${CROWD_INSTALL} && \
  mkdir -p ${CROWD_HOME} && \
  mkdir -p ${CROWD_INSTALL}/apache-tomcat/logs && \
  mkdir -p ${CROWD_INSTALL}/apache-tomcat/work && \
  mkdir -p ${CROWD_INSTALL}/apache-tomcat/temp && \
  mkdir -p ${CROWD_INSTALL}/apache-tomcat/conf && \
  mkdir -p ${CROWD_INSTALL}/database && \
  mkdir -p ${CROWD_INSTALL}/logs && \
  curl -sL https://www.atlassian.com/software/crowd/downloads/binary/atlassian-crowd-${CROWD_VERSION}.tar.gz | tar -zxv -C ${CROWD_INSTALL} --strip-components=1 && \
  echo -e "\ncrowd.home=${CROWD_HOME}" >> "${CROWD_INSTALL}/crowd-webapp/WEB-INF/classes/crowd-init.properties" && \
  chmod 755 ${CROWD_INSTALL}/apache-tomcat/bin/catalina.sh && \
  chown ${CROWD_USER}:${CROWD_GROUP} -R ${CROWD_HOME} && \
  chmod 700 -R ${CROWD_INSTALL}/apache-tomcat/logs && \
  chmod 700 -R ${CROWD_INSTALL}/apache-tomcat/work && \
  chmod 700 -R ${CROWD_INSTALL}/apache-tomcat/temp && \
  chmod 700 -R ${CROWD_INSTALL}/apache-tomcat/conf && \
  chmod 700 -R ${CROWD_INSTALL}/database && \
  chown ${CROWD_USER}:${CROWD_GROUP} -R ${CROWD_INSTALL}/apache-tomcat/logs && \
  chown ${CROWD_USER}:${CROWD_GROUP} -R ${CROWD_INSTALL}/apache-tomcat/work && \
  chown ${CROWD_USER}:${CROWD_GROUP} -R ${CROWD_INSTALL}/apache-tomcat/temp && \
  chown ${CROWD_USER}:${CROWD_GROUP} -R ${CROWD_INSTALL}/apache-tomcat/conf && \
  chown ${CROWD_USER}:${CROWD_GROUP} -R ${CROWD_INSTALL}/database && \
  chown ${CROWD_USER}:${CROWD_GROUP} -R ${CROWD_INSTALL}/logs && \
  curl -sL https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}.tar.gz | \
    tar -zxv -C /tmp mysql-connector-java-${MYSQL_CONNECTOR_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}-bin.jar --strip-components=1 && \
  mv /tmp/mysql-connector-java-${MYSQL_CONNECTOR_VERSION}-bin.jar ${CROWD_INSTALL}/apache-tomcat/lib/ && \

  echo "done"

COPY "docker-entrypoint.sh" "/"

USER ${CROWD_USER}:${CROWD_GROUP}
EXPOSE 8095:8095

VOLUME ["${CROWD_HOME}", "${CROWD_INSTALL}/logs"]

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/opt/atlassian/crowd/apache-tomcat/bin/catalina.sh", "run"]
