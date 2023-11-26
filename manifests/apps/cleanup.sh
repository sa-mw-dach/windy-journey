# --- vars ---
NS=windy-journey
KY=wvi

# --- VARS -----------------------------------------------------
source install_cleanup_vars.sh


if [[ "$CONF_RHODS" == true ]]; then
  oc delete -f rhods/wvi-servingruntime.yaml -n $NS
  oc delete -f rhods/wvi-inference-service.yaml  -n $NS
  oc delete -f rhods/wvi-data-connections.yaml  -n $NS
fi


oc delete -k image-processor/overlays/workshop/ -n $NS >/dev/null