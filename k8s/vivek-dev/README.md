# vivek-dev Kubernetes Resources

Source-controlled non-secret resources for the GPU dev pod.

```bash
kubectl apply -k k8s/vivek-dev
kubectl diff -k k8s/vivek-dev
kubectl rollout status deployment/vivek-dev -n default
```

The Deployment expects these Secrets to exist in `default`:

- `vivek-dev-api-keys`
- `vivek-dev-ssh-authorized-keys`
- `vivek-dev-github-ssh`

The GitHub SSH Secret is also used during first-time Home Manager activation to
clone setup repos such as `~/personal/skills`.

Do not commit Secret values. Recreate or update them from local files with commands like:

```bash
kubectl create secret generic vivek-dev-api-keys \
  -n default \
  --from-env-file=/Users/vkalyan/coreweave/.env \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic vivek-dev-ssh-authorized-keys \
  -n default \
  --from-file=authorized_keys="$HOME/.ssh/vivek-dev.pub" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic vivek-dev-github-ssh \
  -n default \
  --from-file=id_ed25519="$HOME/.ssh/vivek-dev-github" \
  --from-file=id_ed25519.pub="$HOME/.ssh/vivek-dev-github.pub" \
  --dry-run=client -o yaml | kubectl apply -f -
```

The PVC manifest is included for reproducibility, but deleting and recreating the PVC would delete the workspace. Treat PVC deletion as a separate, explicit operation.
