# Infrastructure applications

Add one directory per infrastructure application under this folder. The
`infra-apps` ApplicationSet creates an Argo CD `Application` for each
directory, using the directory name as the application and namespace name.

Example:

```text
k8s/apps/infra/metrics/
  application.yaml
```

The Velero example uses a Helm chart with values from
`k8s/values/infra/velero/values-dev.yaml`. Create the referenced AWS
credentials secret in the `velero` namespace before syncing:

```sh
kubectl create namespace velero
kubectl -n velero create secret generic velero-credentials \
  --from-file=cloud=./credentials-velero
```

Replace `REPLACE_WITH_VELERO_S3_BUCKET` in the values file with an existing S3
bucket in `ap-southeast-1`. Do not commit the credentials file or secret data.
