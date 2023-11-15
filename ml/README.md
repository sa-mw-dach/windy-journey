# Model training for Automating Visual Inspections with AI
Automating Visual Inspections with AI on [Red Hat OpenShift Data Science](https://www.redhat.com/en/technologies/cloud-computing/openshift/openshift-data-science) - Hands-on tutorial

## Prerequisites

### OpenShift with GPU worker nodes 
GPU worker node are not mandatory, but recommended when you would like to train the model by yourself.

- Redhatters, you can order the ["RHODS on OCP on AWS with NVIDIA GPUs"](https://demo.redhat.com/catalog?search=Nvidia). Please be aware of the costs and shutdown the service.


### Provide S3 Storage
Model Serving requires a S3 bucket with an ACCESS_KEY and SECRET_KEY. In case you don't have S3 already available (e.g. ODF or on AWS) you can deploy Minio on your OpenShift Cluster:

```
oc new-project minio
oc apply -f https://raw.githubusercontent.com/sa-mw-dach/windy-journey/main/manifests/infra/05-minio/minio.yaml
```

- Minio is deployed to the project/namespace `minio`.
- Launch the minio web UI (see Route) and create a bucket (e.g. `wvi`).


## Setup a RHODS workbench

### Create new RHODS workbench for Ultralytics Pytorch Yolov5

- Log in to the OpenShift web console
- Launch RHODS via the application launcher (nine-dots) -> **`Red Hat OpenShift Data Science`**
- Create a new Data Science project -> **`Create data science project`**.

  If you have your own OpenShift cluster, you can name the project 'wvi'. If not add your initials. E.g. 'wvi-stb'.
  Don't choose to long names, because project and model server names are internally concatenated, which could lead into problems.

  - Name: `wvi`
  - Resource name: `windy visual inspection `
  - -> **`Create`**.

- Create a data connection with your S3 configuration
  - Data connections -> **`Add Data connections`**.
  - Name: `wvi`
  - AWS_ACCESS_KEY_ID: `minio`
  - AWS_SECRET_ACCESS_KEY: `minio123`
  - AWS_S3_ENDPOINT: `http://minio-service.minio.svc.cluster.local:9000`
  - AWS_DEFAULT_REGION: `us-east2` (it seem this cannot be empty)
  - AWS_S3_BUCKET: `wvi`

- Create new RHODS workbench
  - Workbenches -> **`Create workbench`**.
  - Name: `wvi`
  - Image: `CUDA` (assuming you have a cluster with a Nvidia GPU)
  - Deployment size: `Small`
  - Number of GPUs: 1  
  - Cluster storage: `Create new cluster storage`
  - Data connection: `Use existing data connection` -> `wvi`
  - -> **`Create workbench`**.

- Note, in case the workbench does not start, please check if LimitRanges block the pod.  Find the created project in the OpenShift console, navigate to Administration -> LimitRanges and delete the LimitRange that was auto created.

- Open the workbench and clone  https://github.com/sa-mw-dach/windy-journey.git  (there are at least 4 ways to do this - find out the approach you like)

## Model training

### Explore and run the model training notebook
- Navigate to `windy-journey/ml/pytorch` and open  `01_Visual_Inspection_Yolov5_Model_Training.ipynb`
- Explore or explain and run cells step by step
  - Setup and test the Ultralytics Yolov5 toolkit
  - Inspect training dataset (image and labels)  
  - Model training
    - *Model training can take ~30 minutes or more even with GPUs. You could jump to [Model Serving](#model-serving), use a pre-trained model and come back later.* 
  - Model validation
  - Convert model to onnx format and upload it to S3

Note: the notebook's cells contain output messages from a previous successful run. This is so you could explain the demo without actually run anything (i.e. no GPUs required, etc...). But in order to run the demo yourself, you need to run every cell successfully _once_, even if the outputs might suggest is has already run.

## Model Serving

### Optionally, download a pre-trained wvi model and upload it to S3
In case you have to not had the time or resources to train the model by yourself, you can download a pre-trained wvi model and upload it to your S3 bucket.
- Open your workbench (with your wvi data connection)
- Navigate to `windy-journey/ml/pytorch` and open `02_Visual_Inspection_Upload_Pretrained_Model.ipynb`
- Run the notebook to upload the model

### Configure RHODS model serving
- Create model server in your data science project
  - Models and model servers ->  **`Configure server`**
  - Server name: `wvi`
  - Serving runtime: `OpenVINO Model Server`
  - Number of model server replicas to deploy: `1`
  - Model server size: `Small`
  - Model route: -> `Check/Enable` *'Make deployed models available through an external route'*
  - Token authorization ->  `Uncheck/Disable` *'Require token authentication'*
  - -> **`Configure`**

- Deploy the trained model -> **`Deploy Model`**
  - Model Name: `wvi`
  - Model framework: `onnx - 1`
  - Model location: `Existing data connection`
  - Name: `wvi`
  - Folder path:  `wvi-best.onnx`
  - -> **`Deploy`**

- Wait until Status is green / loaded
  - Copy and save the inference URL

## Test inferencing with a REST API call
Show how an ML REST call could be integrated into your 'intelligent' Python application.

- Return to the workbench
- Navigate to `windy-journey/ml/pytorch` and open  `03_Visual_Inspection_Yolov5_Infer_Rest.ipynb` 
- Study or explain and run cells step by step
  - Please don´t forget to update the inferencing URL 
- Demonstrate cool inferencing with RHODS :-)  