# docker-airflow

## Informations

Based on "puckel/docker-airflow" available here:

    https://github.com/puckel/docker-airflow

This repository only serves as a means to support the "etl-with-airflow" project,
which uses this image in the Hive example

## Installation

Pull the image from the Docker repository.

        docker pull gtoonstra/docker-airflow

## Build

For example, if you need to install [Extra Packages](https://pythonhosted.org/airflow/installation.html#extra-package), edit the Dockerfile and then build it.

        docker build --rm -t gtoonstra/docker-airflow .

