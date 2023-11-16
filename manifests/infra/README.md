![MANUela Logo](https://github.com/sa-mw-dach/manuela/raw/master/docs/images/logo.png)

# Visual Inspection Infrastructure Setup <!-- omit in toc -->

This section describes the installation of the runtime on OpenShift. The model training is described in [ml/README.md](../ml/README.md). And the image annotation is explained in [here](cvat-cnv.md).

- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [Create namespaces](#create-namespaces)
  - [Create a kafka cluster and topic](#create-a-kafka-cluster-and-topic)



## Prerequisites

- S3 compatible object storage such as OpenShift Data Foundation.
- Red Hat OpenShift Data Science (RHODS). (Please refer to this [03-workshop-openshift-data-science.md](../../docs/03-workshop-openshift-data-science.md) to set up an RHODS environment)
- Red Hat OpenShift Serverless Operator is installed (knative)
- Red Hat Integration - AMQ Streams Operator is installed (kafka)
- This repo is cloned into your home directory
- Configured and tested RHODS model server with the visual inspection ML model:

  The Visual Inspection Runtime requires the deployed ML model. Please ensure that model is deployed, by following the steps in [Model Serving](../../docs/03-workshop-openshift-data-science.md#model-serving).
  

## Installation

This installation section describes only the configuration of kafka. The installation is finalized as part of the [Runtime Workshop](../../docs/04-workshop-runtime.md) in the following section.

If not already done, please clone this repository:

```
git clone https://github.com/sa-mw-dach/windy-journey.git
cd windy-journey
```

### Create namespaces

Create the namespace/project via the OpenShift CLI:

```
oc new-project windy-journey
```

Or via the OpenShift WebConsole.

In most cases, these are the common approaches to create resources in OpenShift. We will proceed with applying manifests from this repository. Feel free to take a look at these before applying to understand which resources are being created. A lot of these manifests can be self explanatory with the combination of the content of `kind` and `spec`.

### Create a kafka cluster and topic

Make sure the Red Hat Integration AMQ Streams operator is installed first via the OperatorHub.

Then create a kafka cluster and topic:

```
oc apply -f manifests/infra/02-kafka/kafka-cluster.yaml
```

Wait until the cluster is up and running. E.g.:

```
oc get pods
NAME                                                   READY   STATUS    RESTARTS   AGE
amq-streams-cluster-operator-v1.7.0-67b4df466f-skc8r   1/1     Running   0          17m
wvi-entity-operator-84fbfbcc84-x5dnt               2/3     Running   0          97s
wvi-kafka-0                                        1/1     Running   0          2m12s
wvi-kafka-1                                        1/1     Running   0          2m12s
wvi-kafka-2                                        1/1     Running   0          2m12s
wvi-zookeeper-0                                    1/1     Running   0          3m14s
wvi-zookeeper-1                                    1/1     Running   0          3m14s
wvi-zookeeper-2                                    1/1     Running   0          3m14s

```

Create a topic for the images:

```
oc apply -f manifests/infra/02-kafka/kafka-topic.yaml
```

### Set up Serverless

Make sure the Red Hat Serverless operator is installed first via the OperatorHub.

Instantiate `KnativeServing`:

```
oc apply -f manifests/infra/03-serverless/knative-serving.yaml
```

Instantiate `KnativeEventing`:

```
oc apply -f manifests/infra/03-serverless/knative-eventing.yaml
```

Instantiate `KnativeKafka`:

```
oc apply -f manifests/infra/03-serverless/knative-kafka.yaml
```


