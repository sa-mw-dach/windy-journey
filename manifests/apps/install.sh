# --- vars ---
NS=windy-journey
KY=wvi
KT=visual-inspection-images


# --- VARS -----------------------------------------------------
source install_cleanup_vars.sh


#### Check prerequisites ##########################################

echo "Checking prerequisites..."
PREREQ=true

# --- Project -----------------------------------------------------

oc get project $NS >/dev/null 2>&1
if [[ $? == 0 ]]; then
  echo "✅ Project $NS exists"
else
  echo "👉 Note, please create project $NS..."
  PREREQ=false
fi


oc project $NS >/dev/null 2>&1
if [[ $? == 0 ]]; then
  echo "✅ Project $NS active"
else
  echo "💥 ERROR: Cannot switch to project $NS"
  exit
fi

# --- OpenShift AMQ Streams (Kafka) Operator-----------------------------------------------------
STREAMS_INSTALLED=$(oc get csv -n openshift-operators | grep amqstreams)
if [[ $STREAMS_INSTALLED == *"Succeeded"* ]]; then
  echo "✅ OpenShift AMQ Streams Operator"
else
  echo "👉 Note, please install OpenShift AMQ Streams Operator..."
  PREREQ=false
fi

# --- Kafka Cluster -----------------------------------------------------
oc get Kafka $KY -n $NS >/dev/null 2>&1
if [[ $? == 0 ]]; then
  echo "✅ Kafka Cluster $KY in $NS"
else
    echo "👉 Note, please create Kafka Topic $KY in $NS"
    PREREQ=false
fi

# --- Kafka Topic -----------------------------------------------------
oc get KafkaTopic $KT -n $NS  >/dev/null 2>&1
if [[ $? == 0 ]]; then
  echo "✅ Kafka Topic $KY in $NS"
else
  echo "👉 Note, please create Kafka Topic $KY in $NS"
  PREREQ=false
fi

# --- Check OpenShift Serverless Operator-----------------------------------------------------
KNATIVE_INSTALLED=$(oc get csv -n openshift-operators | grep serverless)
if [[ $KNATIVE_INSTALLED == *"Succeeded"* ]]; then
  echo "✅ OpenShift Serverless Operator"
else
  echo "👉 Note, please install OpenShift Serverless Operator"
  PREREQ=false
fi

# --- Check MINIO  -----------------------------------------------------
oc wait --for=condition=Available deployment/minio --timeout 300s -n minio  >/dev/null 2>&1
if [[ $? == 0 ]]; then
    echo "✅ Minio installed"
else
    echo "👉 Note, please install Minio "
    PREREQ=false
fi

# --- Check RHODS  -----------------------------------------------------
RHODS_INSTALLED=$(oc get csv -n openshift-operators | grep rhods)
if [[ $RHODS_INSTALLED == *"Succeeded"* ]]; then
  echo "✅ OpenShift Data Science Operator"
else
  echo "👉 Note, please install the OpenShift Data Science Operator via the OperatorHub"
  PREREQ=false
fi

if [[ "$PREREQ" == false ]]; then
  echo "💥 ERROR: Check prerequisites"
  exit
else
  echo "Prerequisites ✅"
fi

# Configure RHODS
if [[ "$CONF_RHODS" == true ]]; then

  # --- Create Data Science Project from exiting OpenShift project  -------------
  echo -n "Create Data Science Project ..."
  oc label namespace $NS "opendatahub.io/dashboard=true" "modelmesh-enabled=true" --overwrite >/dev/null
  if [[ $? == 0 ]]; then
      echo "✅ "
  else
      echo "💥 ERROR!"
      exit
  fi

  # ---  Create Data Connection ------------
  echo -n "Create Data Connection ..."
  oc apply -f rhods/wvi-data-connections.yaml -n $NS >/dev/null
  if [[ $? == 0 ]]; then
      echo "✅ "
  else
      echo "💥 ERROR!"
      exit
  fi


  # --- Load a pre-train model into minio bucket (the lazy way)
  BUCKET=wvi
  MODELURL=https://github.com/sa-mw-dach/windy-journey/releases/download/v0.0.0/wind-turbine-weights-best-2023_10_31.onnx

  echo "Load a pre-train model into minio bucket..."

  echo -n "- Create  bucket ..."
  oc exec -n minio deploy/minio -- mkdir -p data/${BUCKET} >/dev/null
  if [[ $? == 0 ]]; then
      echo "✅ "
  else
      echo "💥 ERROR!"
      exit
  fi

  echo -n "- Download model ..."
  oc exec -n minio deploy/minio -- curl -L ${MODELURL} -o data/${BUCKET}/wvi-best.onnx >/dev/null
  if [[ $? == 0 ]]; then
      echo "✅ "
  else
      echo "💥 ERROR!"
      exit
  fi


  # --- Create model server
  echo -n "Create model server ..."
  oc apply -f rhods/wvi-servingruntime.yaml -n $NS >/dev/null
  if [[ $? == 0 ]]; then
      echo "✅ "
  else
      echo "💥 ERROR!"
      exit
  fi

  # --- Create InferenceService
  echo -n "Create InferenceService ."
  oc apply -f rhods/wvi-inference-service.yaml -n $NS >/dev/null
  if [[ $? == 0 ]]; then
      INFSERV_INSTALL_SUCCESS=false
      for i in {1..6}
      do
        echo -n "."
        INFSER_INSTALLED=$(oc get InferenceService wvi -n $NS | grep wvi)
        if [[ $INFSER_INSTALLED == *"True"* ]]; then
            INFSERV_INSTALL_SUCCESS=true
            break
        fi
        sleep 10
      done
      if [[ "$INFSERV_INSTALL_SUCCESS" == true ]]; then
        echo "✅ "
      else
        echo "💥 ERROR!"
      fi
  else
      echo "💥 ERROR!"
      exit
  fi
fi


# --- Create Image Processor Service
echo -n "Create Image Processor Service ..."
oc apply -k image-processor/overlays/workshop/ -n $NS >/dev/null 2>&1
if [[ $? == 0 ]]; then
  sleep 3
  oc wait --for=condition=ready --timeout=60s pod  -l serving.knative.dev/service=image-processor -n $NS >/dev/null
  if [[ $? == 0 ]]; then
    echo "✅ "
  else
      echo "💥 ERROR!"
  fi  
else
  echo "💥 ERROR!"
  exit
fi



