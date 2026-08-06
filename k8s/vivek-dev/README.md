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
- `vivek-dev-kubeconfig`

The GitHub SSH Secret is also used during first-time Home Manager activation to
clone setup repos such as `~/personal/agents`.

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

Create or refresh the kubeconfig Secret with only the contexts the dev pod
should use. Pass context names at runtime so they never appear in this repo:

```bash
dev-pod-kubeconfig-sync \
  --check \
  --host-context "<host-context>" \
  "<host-context>" \
  "<additional-context>"
```

The helper extracts the selected contexts and their credentials from the local
kubeconfig, then applies the resulting config directly as
`Secret/default/vivek-dev-kubeconfig`. The Deployment mounts the Secret
read-only at `/run/secrets/kubeconfig/config`. Refresh the Secret after rotating
its credential; directory-mounted Secret updates are projected into a running
pod without committing or copying the kubeconfig into the workspace. The
example uses `--check`; remove that flag when you are ready to update the Secret.

Verify the mounted contexts from inside the pod without naming them in Git:

```bash
kubectl config get-contexts

for context in $(kubectl config get-contexts -o name); do
  kubectl --context="$context" auth can-i get nodes
done
```

Anyone who can execute commands in the pod can use every credential in this
Secret. Prefer a dedicated, least-privilege credential when one is available.

The PVC manifest is included for reproducibility, but deleting and recreating the PVC would delete the workspace. Treat PVC deletion as a separate, explicit operation.

## SkyPilot

The `vivek-dev` service account has namespace-local dev permissions plus the
cluster-scoped read permissions SkyPilot needs for Kubernetes discovery:

- `nodes`
- `runtimeclasses.node.k8s.io`
- `storageclasses.storage.k8s.io`

SkyPilot also needs to manage namespace-local Secrets for SSH/provisioning.
Inside the pod, `/root/.sky/config.yaml` should contain:

```yaml
kubernetes:
  remote_identity: vivek-dev
```
