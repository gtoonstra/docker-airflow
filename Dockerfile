# VERSION 1.0
# AUTHOR: Matthieu "Puckel_" Roisil
# DESCRIPTION: Basic Airflow container
# BUILD: docker build --rm -t puckel/docker-airflow .
# SOURCE: https://github.com/puckel/docker-airflow

FROM debian:jessie
MAINTAINER gtoonstra

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Airflow
ARG AIRFLOW_VERSION=1.9.0
ARG AIRFLOW_HOME=/usr/local/airflow
ARG HADOOP_DIR=/usr/local/hadoop
ARG HIVE_DIR=/usr/local/hive

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Resolve Hive and Hadoop stuff.
ENV PATH $PATH:$HIVE_DIR/bin:$HADOOP_DIR/bin
ENV HADOOP_HOME $HADOOP_DIR
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
ENV HADOOP_OPTS "$HADOOP_OPTS -Djava.library.path=$HADOOP_HOME/lib/native"
ENV SQOOP_HOME=/usr/lib/sqoop
ENV PATH $PATH:$SQOOP_HOME/bin

RUN set -ex \
    && buildDeps=' \
        python-dev \
        libkrb5-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        build-essential \
        libblas-dev \
        liblapack-dev \
        libpq-dev \
        libgsasl7-dev \
        git \
    ' \
    && apt-get update -yqq \
    && apt-get install -yqq --no-install-recommends \
        $buildDeps \
        python-pip \
        python-requests \
        apt-utils \
        curl \
        netcat \
        locales \
        openjdk-7-jdk \
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow \
    && mkdir ${HADOOP_DIR} \
    && chown -R airflow: ${HADOOP_DIR} \
    && mkdir ${HIVE_DIR} \
    && chown -R airflow: ${HIVE_DIR} \
    && python -m pip install -U pip \
    && pip install Cython \
    && pip install pytz \
    && pip install pyOpenSSL \
    && pip install ndg-httpsclient \
    && pip install pyasn1 \
    && pip install thrift_sasl==0.3.0 \
    && pip install apache-airflow[crypto,celery,gcp_api,postgres,hive,hdfs,jdbc]==$AIRFLOW_VERSION \
    && pip install celery[redis]==3.1.17 \
    && pip install six==1.11.0 \
    && pip install thrift==0.9.3 \
    && apt-get remove --purge -yqq $buildDeps \
    && apt-get clean \
    && mkdir -p /tmp/hadoop \
    && (cd /tmp/hadoop; curl -O https://archive.cloudera.com/cdh5/cdh/5/hadoop-2.6.0-cdh5.11.0.tar.gz) \
    && (cd /tmp/hadoop; tar -zxf hadoop-2.6.0-cdh5.11.0.tar.gz) \
    && (cd /tmp/hadoop; mv hadoop-2.6.0-cdh5.11.0/* ${HADOOP_DIR}) \
    && mkdir -p /tmp/hive \
    && (cd /tmp/hive; curl -O https://archive.cloudera.com/cdh5/cdh/5/hive-1.1.0-cdh5.11.0.tar.gz) \
    && (cd /tmp/hive; tar -zxf hive-1.1.0-cdh5.11.0.tar.gz) \
    && (cd /tmp/hive; mv hive-1.1.0-cdh5.11.0/* ${HIVE_DIR}) \
    && mkdir -p /tmp/sqoop \
    && (cd /tmp/sqoop; curl -O http://apache.40b.nl/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz) \
    && (cd /tmp/sqoop; tar -zxf sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz) \
    && mkdir -p /usr/lib/sqoop \
    && (cd /tmp/sqoop/sqoop-1.4.7.bin__hadoop-2.6.0; mv ./* /usr/lib/sqoop) \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base \
        /tmp/hadoop \
        /tmp/hive \
        /tmp/sqoop

COPY script/entrypoint.sh /entrypoint.sh
COPY config/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

RUN chown -R airflow: ${AIRFLOW_HOME}
RUN chown -R airflow: ${HADOOP_HOME}

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["/entrypoint.sh"]
