# --- vars ---
NS=windy-journey
KY=wvi

# --- VARS -----------------------------------------------------
source install_cleanup_vars.sh

# --- Project -----------------------------------------------------
oc project $NS >/dev/null 2>&1
if [[ $? == 0 ]]; then
  echo "✅ Project $NS active"
else
  echo "💥 ERROR: Cannot switch to project $NS"
  exit
fi

# --- Kafka Topic -----------------------------------------------------
if [[ "$CONF_KAFKA" == true ]]; then
    oc delete -f  02-kafka/kafka-topic.yaml -n $NS
    echo "... deleting kafka topic"
fi

# --- Kafka Cluster -----------------------------------------------------
if [[ "$INST_KAFKA" == true ]]; then
    oc delete -f  02-kafka/kafka-cluster.yaml -n $NS
    echo "... deleting kafka cluster" 
    oc wait --for delete pod --timeout=500s --selector=app.kubernetes.io/name=kafka
fi


# --- OpenShift Serverless Setup -----------------------------------------------------
if [[ "$CONF_KNATIVE" == true ]]; then
    echo "Delete OpenShift Serverless Setup..."
    oc delete -f 03-serverless/knative-serving.yaml
    oc delete -f 03-serverless/knative-eventing.yaml
    oc delete -f 03-serverless/knative-kafka.yaml
fi

# --- Delete MINIO  -----------------------------------------------------
if [[ "$INST_MINIO" == true ]]; then 
    echo "Delete Minio..."
    oc delete -f 05-minio/minio.yaml -n minio
fi 