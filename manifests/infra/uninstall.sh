# --- vars ---
NS=windy-journey
KY=wvi


# --- Kafka Topic -----------------------------------------------------
oc delete -f  02-kafka/kafka-topic.yaml -n $NS
echo "... deleting kafka topic"

# --- Kafka Cluster -----------------------------------------------------
oc delete -f  02-kafka/kafka-cluster.yaml -n $NS
echo "... deleting kafka cluster" 
oc wait --for delete pod --timeout=500s --selector=app.kubernetes.io/name=kafka

# --- OpenShift Serverless Setup -----------------------------------------------------
echo "Delete OpenShift Serverless Setup..."
oc delete -f 03-serverless/knative-serving.yaml
oc delete -f 03-serverless/knative-eventing.yaml
oc delete -f 03-serverless/knative-kafka.yaml