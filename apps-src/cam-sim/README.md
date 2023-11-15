# Camera Simulator for the Visual Inspections workshop


## Build and test container image locally


### Build
```
podman build -t cam-sim -f Containerfile
```

### Test

Run the container on your local system and send the images to a Kafka on OpenShift.

Port forwarding to the kafka bootstrap service port:
```
oc port-forward service/wvi-kafka-bootstrap 9092:9092 -n windy-journey
```

Run the cam-sim container:
```
podman run  -it --rm --network=host cam-sim
```
