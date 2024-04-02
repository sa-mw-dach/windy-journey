
# Build custom notebook image

## Clone Ultralytics Yolov5
```
git clone https://github.com/ultralytics/yolov5
```


## Build and test locally
```
podman build -t windy-journey-notebook:test -f Containerfile
podman run  -it --rm -p 8888:8888 windy-journey-notebook:test
```


## Push to Quay
```
podman tag windy-journey-notebook:test quay.io/wvi/notebooks:wvi-pypytorch-20240402
podman push quay.io/wvi/notebooks:wvi-pypytorch-20240402
```

## Remove Ultralytics Yolov5
```
rm -rf yolov5
```