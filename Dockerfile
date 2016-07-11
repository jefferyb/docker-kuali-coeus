#
# Kuali Coeus on MySQL Server
#
# https://github.com/jefferyb/docker-mysql-kuali-coeus
#
# To Build:
#    docker build -t jefferyb/kuali_coeus .
#
# To Run:
#    docker run -d --name kuali_coeus -h EXAMPLE.COM -p 8080:8080 -p 43306:3306 jefferyb/kuali_coeus
#

# Pull base image.
FROM ubuntu:14.04
MAINTAINER Jeffery Bagirimvano <jeffery.rukundo@gmail.com>

# MySQL Settings:
RUN mkdir -p /setup_files
ADD setup_files /setup_files
ENV HOST_NAME kuali_coeus

# Tomcat Settings:
ENV TOMCAT_LOCATION="/opt/apache-tomcat/tomcat8"
ENV KC_CONFIG_XML_LOC="/opt/kuali/main/dev"

# MySQL Connector Java
ENV MYSQL_CONNECTOR_LINK="http://mirror.cogentco.com/pub/mysql/Connector-J/mysql-connector-java-5.1.34.zip"
ENV MYSQL_CONNECTOR_ZIP_FILE="mysql-connector-java-5.1.34.zip"
ENV MYSQL_CONNECTOR_FILE="mysql-connector-java-5.1.34/mysql-connector-java-5.1.34-bin.jar"

# Tomcat - Spring Instrumentation
ENV SPRING_INSTRUMENTATION_TOMCAT_LINK="http://central.maven.org/maven2/org/springframework/spring-instrument-tomcat/3.2.13.RELEASE/spring-instrument-tomcat-3.2.13.RELEASE.jar"


# Install MySQL.
RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server-5.5 git && \
  echo $(head -1 /etc/hosts | cut -f1) ${HOST_NAME} >> /etc/hosts && \
  sed -i 's/^\(bind-address\s.*\)/# \1/' /etc/mysql/my.cnf && \
  sed -i 's/^\(log_error\s.*\)/# \1/' /etc/mysql/my.cnf && \
  echo "mysqld_safe &" > /tmp/config && \
  echo "mysqladmin --silent --wait=30 ping || exit 1" >> /tmp/config && \
  echo "mysql -e 'GRANT ALL PRIVILEGES ON *.* TO \"root\"@\"%\" WITH GRANT OPTION;'" >> /tmp/config && \
  bash /tmp/config && \
  rm -f /tmp/config && \
	mysqladmin -u root password Chang3m3t0an0th3r && \
	mysqladmin -u root -pChang3m3t0an0th3r -h ${HOST_NAME} password Chang3m3t0an0th3r && \
	cp -f /setup_files/my.cnf /etc/mysql/my.cnf && \
	mysql -u root -pChang3m3t0an0th3r < /setup_files/configure_mysql.sql && \
	service mysql restart && \
	cd setup_files; ./install_kuali_db.sh && \
	echo "Done Setting up MySQL!!!"

# Install Tomcat
RUN \

	apt-get install -y curl && \
	TOMCAT_MAJOR="8" && \
	TOMCAT_VERSION="$(curl -s https://tomcat.apache.org/download-80.cgi | grep -A 7 '</select><input type="submit" value="Change">' | grep '<h3 id="' | sed 's/<h3 id="//' | sed 's/">.*//')" && \
	TOMCAT_LINK="https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz" && \
	TOMCAT_FILE="apache-tomcat-${TOMCAT_VERSION}.tar.gz" && \

	apt-get install -y software-properties-common && \
	add-apt-repository -y ppa:webupd8team/java && \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
	apt-get update && \
	apt-get install -y wget zip unzip oracle-java8-installer tar graphviz && \
	cd /setup_files  && \
	wget ${TOMCAT_LINK} && \
	mkdir -p ${TOMCAT_LOCATION} && \
	tar --strip-components=1 -zxvf ${TOMCAT_FILE} -C ${TOMCAT_LOCATION} && \
	wget ${MYSQL_CONNECTOR_LINK} && \
	unzip -j ${MYSQL_CONNECTOR_ZIP_FILE} ${MYSQL_CONNECTOR_FILE} -d ${TOMCAT_LOCATION}/lib && \
	cp /setup_files/setenv.sh ${TOMCAT_LOCATION}/bin && \
	cd ${TOMCAT_LOCATION}/lib && \
	wget ${SPRING_INSTRUMENTATION_TOMCAT_LINK} && \
	sed -i 's/<Context>/<Context>\n    <!-- END - For Kuali Coeus - Jeffery B. -->/' ${TOMCAT_LOCATION}/conf/context.xml && \
	sed -i 's/<Context>/<Context>\n    <Loader loaderClass="org.springframework.instrument.classloading.tomcat.TomcatInstrumentableClassLoader"\/>/' ${TOMCAT_LOCATION}/conf/context.xml && \
	sed -i 's/<Context>/<Context>\n\n    <!-- BEGIN - For Kuali Coeus -->/' ${TOMCAT_LOCATION}/conf/context.xml && \
	mkdir -p ${KC_CONFIG_XML_LOC} && \
	cp -f /setup_files/kc-config.xml ${KC_CONFIG_XML_LOC}/kc-config.xml && \

	KC_VERSION="$(curl -s https://raw.githubusercontent.com/kuali/kc/master/pom.xml | egrep -m 1 "<version>" | sed 's/<version>//' | sed 's/\..*//' | awk '{print $1}')" && \
	KC_WAR_FILE_LINK="http://www.kuali.erafiki.com/${KC_VERSION}/mysql/kc-dev.war" && \
	KC_PROJECT_RICE_XML="http://www.kuali.erafiki.com/${KC_VERSION}/xml_files/rice-xml-${KC_VERSION}.zip" && \
	KC_PROJECT_COEUS_XML="http://www.kuali.erafiki.com/${KC_VERSION}/xml_files/coeus-xml-${KC_VERSION}.zip" && \

	wget ${KC_WAR_FILE_LINK} -O ${TOMCAT_LOCATION}/webapps/kc-dev.war && \
	mkdir -p ${TOMCAT_LOCATION}/webapps/ROOT/xml_files && \
	wget ${KC_PROJECT_RICE_XML} -O ${TOMCAT_LOCATION}/webapps/ROOT/xml_files/rice-xml-$(echo ${KC_VERSION} | sed 's/coeus-//').zip && \
	wget ${KC_PROJECT_COEUS_XML} -O ${TOMCAT_LOCATION}/webapps/ROOT/xml_files/coeus-xml-$(echo ${KC_VERSION} | sed 's/coeus-//').zip && \
	rm -fr /setup_files && \
	echo "Done Setting Tomcat!!!"

# Expose ports.
EXPOSE 3306 8080

# Define default command.
CMD export TERM=vt100; sed -i "3 s/localhost/$(hostname -f)/" ${KC_CONFIG_XML_LOC}/kc-config.xml; sed -i "s/Kuali-Coeus-Version/KualiCo ${KC_VERSION}/" ${KC_CONFIG_XML_LOC}/kc-config.xml; service mysql restart; ${TOMCAT_LOCATION}/bin/startup.sh; tailf ${TOMCAT_LOCATION}/logs/catalina.out
