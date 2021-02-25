#!/bin/sh

# generate xnat config
if [ ! -f ${XNAT_HOME}/config/xnat-conf.properties ]; then
  cat > ${XNAT_HOME}/config/xnat-conf.properties << EOF
datasource.driver=${XNAT_DATASOURCE_DRIVER}
datasource.url=${XNAT_DATASOURCE_URL}
datasource.username=${XNAT_DATASOURCE_USERNAME}
datasource.password=${XNAT_DATASOURCE_PASSWORD}

hibernate.dialect=${XNAT_HIBERNATE_DIALECT}
hibernate.hbm2ddl.auto=update
hibernate.show_sql=false
hibernate.cache.use_second_level_cache=true
hibernate.cache.use_query_cache=true

spring.activemq.broker-url=${XNAT_ACTIVEMQ_URL}
spring.activemq.user=${XNAT_ACTIVEMQ_USERNAME}
spring.activemq.password=${XNAT_ACTIVEMQ_PASSWORD}

spring.http.multipart.max-file-size=1073741824
spring.http.multipart.max-request-size=1073741824
EOF
fi

mkdir -p /usr/local/share/xnat
cp ${XNAT_HOME}/config/xnat-conf.properties /usr/local/share/xnat

[[ "${INSTALL_PIPELINE}" == "false" ]] && { echo "Skipping pipeline installation"; exit 0; }

wget --quiet --output-file=${XNAT_PIPELINE_ARCHIVE} ${XNAT_PIPELINE_URL}
unzip -qq ${XNAT_PIPELINE_ARCHIVE}
cd xnat-pipeline

cat > gradle.properties << GRADLE_PROPS
xnatUrl=${XNAT_PROCESSING_URL}
siteName=XNAT
adminEmail=${XNAT_EMAIL}
smtpServer=${SMTP_HOSTNAME}
destination=/data/xnat/pipeline
GRADLE_PROPS

./gradlew
cd ..
rm -rf ${XNAT_PIPELINE_ARCHIVE} xnat-pipeline

