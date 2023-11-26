# --- vars ---
NS=windy-journey
KY=wvi
KT=visual-inspection-images


# --- VARS -----------------------------------------------------
source install_cleanup_vars.sh

# --- Project -----------------------------------------------------

if [[ "$CREATE_PROJECT" == true ]]; then
  oc get project $NS >/dev/null 2>&1
  if [[ $? == 0 ]]; then
    echo "✅ Project $NS exists"
  else
    echo "-> Create project $NS..."
    oc new-project $NS >/dev/null
    if [[ $? == 0 ]]; then
      echo "✅ Project $NS created"
    else
      echo "💥 ERROR: Cannot create project $NS"
      exit 
    fi
  fi
fi

oc project $NS >/dev/null 2>&1
if [[ $? == 0 ]]; then
  echo "✅ Project $NS active"
else
  echo "💥 ERROR: Cannot switch to project $NS"
  exit
fi



if [[ "$INST_KAFKA" == true ]]; then
  # --- OpenShift AMQ Streams (Kafka) Operator-----------------------------------------------------
  STREAMS_INSTALLED=$(oc get csv -n openshift-operators | grep amqstreams)
  if [[ $STREAMS_INSTALLED == *"Succeeded"* ]]; then
    echo "✅ OpenShift AMQ Streams Operator"
  else
    echo "-> Installing OpenShift AMQ Streams Operator..."

    read -r -d '' YAML_CONTENT <<EOF
  apiVersion: operators.coreos.com/v1alpha1
  kind: Subscription
  metadata:
    labels:
      operators.coreos.com/amq-streams.openshift-operators: ""
    name: amq-streams
    namespace: openshift-operators
  spec:
    channel: stable
    installPlanApproval: Automatic
    name: amq-streams
    source: redhat-operators
    sourceNamespace: openshift-marketplace
    startingCSV: amqstreams.v2.4.0-0
EOF
    echo "$YAML_CONTENT" | oc apply -f -
    sleep 5
    oc wait --for=condition=initialized --timeout=60s pods -l name=amq-streams-cluster-operator -n openshift-operators
  fi

  # --- Kafka Cluster -----------------------------------------------------
  oc get Kafka $KY -n $NS >/dev/null 2>&1
  if [[ $? == 0 ]]; then
    echo "✅ Kafka Cluster $KY in $NS"
  else
    echo "-> Create Kafka Cluster $KY in $NS..."
    oc apply -f  02-kafka/kafka-cluster.yaml -n $NS >/dev/null
    if [[ $? == 0 ]]; then
      echo "... creating  Kafka Cluster $KY in $NS..."
    else
      exit 
    fi

    sleep 20
    echo "... wait for zookeeper..."
    oc wait --for=condition=ready --timeout=600s pods -l strimzi.io/controller-name=wvi-zookeeper -n $NS && \
      echo "✅ Kafka Cluster $KY in $NS" || exit

    sleep 20
    echo "... wait for kafka..."
    oc wait --for=condition=ready --timeout=600s pods -l strimzi.io/controller-name=wvi-kafka -n $NS && \
      echo "✅ Kafka Cluster $KY in $NS" || exit
  fi

fi 

if [[ "$CONF_KAFKA" == true ]]; then
  # --- Kafka Topic -----------------------------------------------------
  oc get KafkaTopic $KT -n $NS  >/dev/null 2>&1
  if [[ $? == 0 ]]; then
    echo "✅ Kafka Topic $KY in $NS"
  else
    echo "-> Create Kafka Topic $KY in $NS..." 
    oc apply -f  02-kafka/kafka-topic.yaml -n $NS >/dev/null
    if [[ $? == 0 ]]; then
      echo "... creating Kafka Topic $KY in $NS..."
    else
      exit 
    fi   
  fi
fi

# --- OpenShift Serverless Operator-----------------------------------------------------
if [[ "$INST_KNATIVE" == true ]]; then

  KNATIVE_INSTALLED=$(oc get csv -n openshift-operators | grep serverless)
  if [[ $KNATIVE_INSTALLED == *"Succeeded"* ]]; then
    echo "✅ OpenShift Serverless Operator"
  else
    echo "-> Installing OpenShift Serverless Operator..."

    read -r -d '' YAML_CONTENT <<EOF
  ---
  apiVersion: v1
  kind: Namespace
  metadata:
    name: openshift-serverless
  ---
  apiVersion: operators.coreos.com/v1
  kind: OperatorGroup
  metadata:
    name: serverless-operators
    namespace: openshift-serverless
  spec: {}
  ---
  apiVersion: operators.coreos.com/v1alpha1
  kind: Subscription
  metadata:
    name: serverless-operator
    namespace: openshift-serverless
  spec:
    channel: stable 
    name: serverless-operator 
    source: redhat-operators 
    sourceNamespace: openshift-marketplace 
EOF
    echo "$YAML_CONTENT" | oc apply -f -
    sleep 10
    oc wait --for=condition=initialized --timeout=60s pods -l name=knative-openshift -n openshift-serverless
  fi

fi

# --- OpenShift Serverless Setup -----------------------------------------------------
if [[ "$CONF_KNATIVE" == true ]]; then
  echo "Configure OpenShift Serverless..."
  oc apply -f 03-serverless/knative-serving.yaml
  oc apply -f 03-serverless/knative-eventing.yaml
  oc apply -f 03-serverless/knative-kafka.yaml
fi


# --- Install MINIO  -----------------------------------------------------
if [[ "$INST_MINIO" == true ]]; then
  oc get project minio >/dev/null 2>&1
  if [[ $? == 0 ]]; then
    echo "✅ Project minio exists"
  else
    echo "-> Create project minio..."
    oc new-project minio >/dev/null
    if [[ $? == 0 ]]; then
      echo "✅ Project minio created"
    else
      echo "💥 ERROR: Cannot create project minio"
      exit 
    fi
  fi

  oc project minio >/dev/null 2>&1
  if [[ $? == 0 ]]; then
    echo "✅ Project minio active"
  else
    echo "💥 ERROR: Cannot switch to project minio"
    exit
  fi

  oc apply -f 05-minio/minio.yaml -n minio
  sleep 5
  oc wait --for=condition=Available deployment/minio --timeout 300s -n minio
  if [[ $? == 0 ]]; then
      echo "✅ Minio installed"
    else
      echo "💥 ERROR: Minio installion failed"
      exit      
    fi
fi


RHODS_INSTALLED=$(oc get csv -n openshift-operators | grep rhods)
if [[ $RHODS_INSTALLED == *"Succeeded"* ]]; then
  echo "✅ OpenShift Data Science Operator"
else
  echo "👉 Note, please install the OpenShift Data Science Operator via the OperatorHub"
fi