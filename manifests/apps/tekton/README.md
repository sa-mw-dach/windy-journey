# Build container images

## Prerequisites

Create a windy-journey project/namespace, if not already exists:
```
oc new-project windy-journey --display-name='Wind Turbine Visual Inspection'
```

## Setup secret for Quay.io credentials

### Option 1: Use your personal Quay.io account
to-do: describe steps to create repos and push secrect.

### Option 2: Use Red Hat's WVI Quay.io account
- Login to Quay.io
- Navigate to wvi organization
- Navigate to wvi+push_robot robot account
- View credentials
- Download Download wvi-push-robot-secret.yml to secrets/


- Push and link secret:
```
oc apply -f secrets/wvi-push-robot-secret.yml -n windy-journey
oc secret link pipeline wvi-push-robot-pull-secret -n windy-journey
```

## Deploy Pipeline and start runs
```
oc apply -k .
``````