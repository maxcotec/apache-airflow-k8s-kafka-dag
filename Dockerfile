FROM apache/airflow:3.0.6 AS base

RUN pip install apache-airflow-providers-common-messaging==2.0.1
RUN pip install apache-airflow-providers-apache-kafka==1.11.1
