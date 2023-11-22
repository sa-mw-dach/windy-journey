# Windy Journey | Data Science meets wind turbines!

This repository serves as the foundation for the Windy Journey workshop. It contains all the neccessary manifests and steps to reproduce the used stack and approaches from the workshop.

## What to expect

In the workshop (and by following along the documentation here), you will get in touch with various tools for an (opnitionated) AI/ML workflow. These tools for example include: `PyTorch`, `Jupyter Notebooks`, `Kafka`, `Knative`, `MinIO`, `OpenShift (with OpenShift Data Science)` and others. You will set those up and be able to understand how these components interact with each other. You will be able to set up and initiate the training of a model, make it available for inferencing and deploy the infrastructure and runtimes, all in a cloud native fashion on Kubernetes (OpenShift).

## Outcome

You will have set up the (opinionated) AI/ML workflow which will simulate live footage capture of wind turbine images which will be distributed over `Kafka` to services running on demand via `Knative` which again use the trained model residing in a S3 bucket with `MinIO` to detect anomalies and annotate these accordingly. These annotaed images will ultimately be displayed in a web UI to have a visual representation of potential anomalies.

## Folder structure

This repository serves as a mono repository containing source codes of applications for this use case as well as manifests (yamls) to deploy resources on OpenShift. Usually you will split applications and infrastructure resources in separate repositories with different responsibilities. FOr the sake of this workshop and to make it easier accessible, we merged it all into one.

### /apps-src

Applications developed and used to realise the workflow of gathering images, annotating them and displaying them for users.

| Folder                     | Description                                                                                                                                                                                                                                                                            |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| /cam-sim                   | CamSimulator: python application which streams the raw images of wind turbines. Could in practice be streamed from a drone for example                                                                                                                                                 |
| /image-processor           | ImageProcessor: grabs the image stream from the CamSimulator (cloud event via Kafka) to inference them with our trained model to annotate them if a damage is found                                                                                                                    |
| /ui/fontend && /ui/backend | UI: a backend written with NestJS to grab the images from the ImageProcessor (again cloud event via Kafka) and sends those to clients connected via WebSocket. Frontend written with Flutter to connect to the WebSocket of the backend to listen for images and display them properly |

### /docs

...

### /manifests

...

### /ml

...
