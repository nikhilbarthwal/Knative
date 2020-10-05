# Initial Setup

export KNATIVE_VERSION="0.16.0"
export PROJECT_ID="peaceful-fact-291520"
export CLUSTER_NAME="knative"
export CLUSTER_ZONE="europe-west1-b"
export CLUSTER_START_NODE_SIZE=3
export CLUSTER_MAX_NODE_SIZE=10
export CLUSTER_NODE_MACHINE_TYPE="n1-standard-4"
export CLUSTER_MASTER_VERSION="latest"

# Enable APIs
gcloud services enable cloudapis.googleapis.com container.googleapis.com containerregistry.googleapis.com

# Create a cluster
gcloud beta container clusters create ${CLUSTER_NAME} \
  --addons HorizontalPodAutoscaling,HttpLoadBalancing,Istio \
  --zone ${CLUSTER_ZONE} \
  --cluster-version ${CLUSTER_MASTER_VERSION} \
  --machine-type ${CLUSTER_NODE_MACHINE_TYPE} \
  --num-nodes ${CLUSTER_START_NODE_SIZE} \
  --min-nodes 1 \
  --max-nodes ${CLUSTER_MAX_NODE_SIZE} \
  --enable-ip-alias \
  --enable-stackdriver-kubernetes \
  --enable-autoscaling \
  --enable-autorepair \
  --scopes cloud-platform


# Cluster role binding
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value core/account)

kubectl apply --selector knative.dev/crd-install=true \
  --filename "https://github.com/knative/serving/releases/download/v${KNATIVE_VERSION}/serving.yaml" \
  --filename "https://github.com/knative/serving/releases/download/v${KNATIVE_VERSION}/release.yaml" \
  --filename "https://github.com/knative/serving/releases/download/v${KNATIVE_VERSION}/monitoring.yaml"


kubectl apply --filename "https://github.com/knative/serving/releases/download/v${KNATIVE_VERSION}/serving.yaml" \
  --filename "https://github.com/knative/serving/releases/download/v${KNATIVE_VERSION}/release.yaml" \
  --filename "https://github.com/knative/serving/releases/download/v${KNATIVE_VERSION}/monitoring.yaml"

# Test everything is correct
kubectl get pods -n knative-serving
kubectl get pods -n knative-eventing
kubectl get pods -n knative-monitoring
