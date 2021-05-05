#!/bin/bash

################################################################################
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################
# Wait for heathy ElasticSearch
# next wait for ES status to turn to Green
health_check="$(curl -u "$UNOMI_ELASTICSEARCH_USERNAME:$UNOMI_ELASTICSEARCH_PASSWORD" "https://$UNOMI_ELASTICSEARCH_ADDRESSES/_cat/health?h=status")"

until ([ "$health_check" = 'yellow' ] || [ "$health_check" = 'green' ]); do
	health_check="$(curl -u "$UNOMI_ELASTICSEARCH_USERNAME:$UNOMI_ELASTICSEARCH_PASSWORD" "https://$UNOMI_ELASTICSEARCH_ADDRESSES/_cat/health?h=status")"
    >&2 echo "Elastic Search is not yet available - waiting (health check=$health_check)..."
    sleep 1
done

# config settings to connect elasticsearch service:
# sed -i "s%elasticSearchAddresses=\${org\.apache\.unomi\.elasticsearch\.addresses\:\-localhost\:9200}%elasticSearchAddresses=\${org\.apache\.unomi\.elasticsearch\.addresses\:\-$UNOMI_ELASTICSEARCH_ADDRESSES}%g" /opt/apache-unomi/etc/org.apache.unomi.persistence.elasticsearch.cfg
# sed -i "s/cluster\.name=\${org\.apache\.unomi\.elasticsearch\.cluster\.name\:\-contextElasticSearch}/cluster\.name=\${org\.apache\.unomi\.elasticsearch\.cluster\.name\:\-$UNOMI_ELASTICSEARCH_CLUSTER_NAME}/g" /opt/apache-unomi/etc/org.apache.unomi.persistence.elasticsearch.cfg
# sed -i "s/username=\${org\.apache\.unomi\.elasticsearch\.username\:\-}/username=\${org\.apache\.unomi\.elasticsearch\.username\:\-$UNOMI_ELASTICSEARCH_USERNAME}/g" /opt/apache-unomi/etc/org.apache.unomi.persistence.elasticsearch.cfg
# sed -i "s/password=\${org\.apache\.unomi\.elasticsearch\.password\:\-}/password=\${org\.apache\.unomi\.elasticsearch\.password\:\-$UNOMI_ELASTICSEARCH_PASSWORD}/g" /opt/apache-unomi/etc/org.apache.unomi.persistence.elasticsearch.cfg
# sed -i "s/sslEnable=\${org\.apache\.unomi\.elasticsearch\.sslEnable\:\-false}/sslEnable=\${org\.apache\.unomi\.elasticsearch\.sslEnable\:\-true}/g" /opt/apache-unomi/etc/org.apache.unomi.persistence.elasticsearch.cfg
sed -i "s/org\.apache\.unomi\.elasticsearch\.sslEnable=\${env\:UNOMI_ELASTICSEARCH_SSL_ENABLE\:\-false}/org\.apache\.unomi\.elasticsearch\.sslEnable=\${env\:UNOMI_ELASTICSEARCH_SSL_ENABLE\:\-true}/g" /opt/apache-unomi/etc/custom.system.properties
# sed -i "s/sslTrustAllCertificates=\${org\.apache\.unomi\.elasticsearch\.sslTrustAllCertificates\:\-false}/sslTrustAllCertificates=\${org\.apache\.unomi\.elasticsearch\.sslTrustAllCertificates\:\-true}/g" /opt/apache-unomi/etc/org.apache.unomi.persistence.elasticsearch.cfg


$UNOMI_HOME/bin/start
$UNOMI_HOME/bin/status # Call to status delays while Karaf creates karaf.log

tail -f $UNOMI_HOME/data/log/karaf.log
