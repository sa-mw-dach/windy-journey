# Windy Journey | Data Science meets wind turbines!

This repository serves as the foundation for the Windy Journey workshop. It contains all the neccessary manifests and steps to reproduce the used stack and approaches from the workshop.

## What to expect

In the workshop (and by following along the documentation here), you will get in touch with various tools for an (opnitionated) AI/ML workflow. These tools for example include: `PyTorch`, `Jupyter Notebooks`, `Kafka`, `Knative`, `MinIO`, `OpenShift (with OpenShift Data Science)` and others. You will set those up and be able to understand how these components interact with each other. You will be able to set up and initiate the training of a model, make it available for inferencing and deploy the infrastructure and runtimes, all in a cloud native fashion on Kubernetes (OpenShift).

## Outcome

You will have set up the (opinionated) AI/ML workflow which will simulate live footage capture of wind turbine images which will be distributed over `Kafka` to services running on demand via `Knative` which again use the trained model residing in a S3 bucket with `MinIO` to detect anomalies and annotate these accordingly. These annotaed images will ultimately be displayed in a web UI to have a visual representation of potential anomalies.

## Folder structure

### /apps-src

Source code for the applications used as part of this workshop

### /apps-src/cam-sim

Application which is emulating a camera and is sending out images as a stream

...

- manifests
  - infra
    - 01-Operators
      - Minio (manifest vion MaxM)
    - 02-Kafka
    - 03-Serverless
    - 03-OpenShift-Data-Science
    -
  - ## apps
- docs
  - OpenShift-installation.md
  - Install-prerequisites.md
  - Workshop-OpenShift-Data-Science.md
  - Workshop-Runtime.md
  - images/
