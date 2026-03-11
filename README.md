# Apache Airflow 3 on Kubernetes 

In this tutorial, we are going to spin Apache airflow 3 on Kubernetes which ofcourse use KubernetesExecutor. 
This repository is clone of https://github.com/maxcotec/ApacheAirflow3-k8s, 
with additional info about Kafka connection details. 

Watch original video on how to setup airflow on Kubernetes;

https://youtu.be/zKGvgR6rla0
![youtube video.jpg](youtube%20video.jpg)
Watch video on how to use this setup to event-based DAG which triggers on Kafka messages;
<video link here>

This repository uses DAG code located here 
https://github.com/maxcotec/apache-airflow-events-trigger

## Requirements: 

following are the list of tools and their versions used in this tutorial; 
### [rancher-desktop](https://rancherdesktop.io/): 

```1.20.0 (using Dockerd container engine)```

### [kubectl](https://kubernetes.io/docs/reference/kubectl/): 
A command line tool for communicating with a Kubernetes cluster.
```
Client Version: v1.34.0
Kustomize Version: v5.7.1
Server Version: v1.33.4+k3s1
```

### [k9s](https://k9scli.io/): 
CLI tool to manage your k8s clusters.

```0.40.5```


### [helm](https://helm.sh/): 
The package manager for Kubernetes

```version.BuildInfo{Version:"v3.18.6", GitCommit:"b76a950f6835474e0906b96c9ec68a2eff3a6430", GitTreeState:"clean", GoVersion:"go1.24.6"}```

### [Nfs Server provisioner](https://artifacthub.io/packages/helm/kvaps/nfs-server-provisioner): 
A dynamic provisioner for Kubernetes, to quickly & easily deploy shared storage that works almost anywhere.
Airflow logs needs ReadWriteMany storage class. With NFS server, we'll create this.
```
helm Chart version nfs-server-provisioner-1.8.0
App version 4.0.8
```

### Apache Airflow: 

This project requires additional packages to be installed on top of airflow base image. 
Use the provided Dockerfile to build image and tag it as follows `apache-airflow-kafka-trigger:latest`
See below on how to build Docker image from Rancher.

### Rancher build image

Open Rancher Desktop main window, go to `images`>`Add Image`>`Build`.
Name of the image to build: `apache-airflow-kafka-trigger:latest`
Click `Build`, then locate the provided Dockerfile.

if build fails with following error;

```shell
Dockerfile:1 -------------------- 1 | 
>>> FROM apache/airflow:3.0.6 AS base 2 | 3 | 
RUN pip install apache-airflow-providers-common-messaging==2.0.1 
ERROR: failed to build: failed to solve: DeadlineExceeded: 
DeadlineExceeded: apache/airflow:3.0.6: failed to resolve source metadata 
for docker.io/apache/airflow:3.0.6: failed to do request: 
Head "https://registry-1.docker.io/v2/apache/airflow/manifests/3.0.6": dial tcp 3.213.195.180:443: i/o timeout
```

Open rancher desktop terminal, and pull base image first;
```shell
rdctl shell
docker pull apache/airflow:3.0.6
```
Then build your custom image again.

### Apache-Kafka

use this code https://github.com/maxcotec/apache-kafka to spin up local kafka instance (+ Kafka UI)
into your local machine. 
```shell
cd kafka
docker-compose up . 
```

## Prep work
Before deploying airflow, there are few things to set up first. 

### K8s Cluster
Be sure rancher has spun up your k8s cluster and rite context is selected. By default, rancher names the k8s context as `rancher-desktop`. 
Check if its present in context list. type `kubectl config get-contexts` to list all your k8s clusters contexts.
Then type `kubectl config use-context rancher-desktop`

Create a namespace `airflow` 

```
kubectl create namespace airflow
```

## Deploy instructions

1. Initialize helm chart `helm create <your chart name>`

```shell
helm create maxcotec-airflow3
```
This should create a directory `maxcotec-airflow3` with example templates and value.yaml file. 
delete all example template files under templates/ directory. and clear the values.yaml.

2. Update helm dependencies

Go inside your chart directory `cd maxcotec-airflow3`
```shell
helm dependency update
```
This should download all three dependent charts airflow, mysql and nfs

3. install the chart

```shell
helm upgrade --install airflow . -n airflow --create-namespace -f our-values.yaml
```

4. uninstall the chart

```shell
helm uninstall airflow -n airflow
```

