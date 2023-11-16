# --- vars ---
NS=windy-journey
KY=wvi
KT=visual-inspection-images

# --- Project -----------------------------------------------------

oc get project $NS >/dev/null 2>&1
if [[ $? == 0 ]]; then
   echo "✅ Project $NS"
else
   echo "-> Create project $NS..."
   oc new-project $NS >/dev/null
   if [[ $? == 0 ]]; then
     echo "✅ Project $NS"
   else
     exit 
   fi
fi

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

# --- OpenShift Serverless Operator-----------------------------------------------------
STREAMS_INSTALLED=$(oc get csv -n openshift-operators | grep serverless)
if [[ $STREAMS_INSTALLED == *"Succeeded"* ]]; then
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


# --- OpenShift Serverless Setup -----------------------------------------------------
echo "Configure OpenShift Serverless..."
oc apply -f 03-serverless/knative-serving.yaml
oc apply -f 03-serverless/knative-eventing.yaml
oc apply -f 03-serverless/knative-kafka.yaml

