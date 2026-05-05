# Bootstrap destroy with unreachable cluster

## Problem

When `make destroy` runs after the K3s control plane is already gone, Terraform can still have in-cluster resources in state. The first failing case here was `kubernetes_namespace_v1.cni_np_test`, which forced the Kubernetes provider to call `https://127.0.0.1:6443` during destroy and stopped the teardown.

## Change applied

The destroy flow in [00.bootstrap/Makefile](../00.bootstrap/Makefile) now removes these additional Kubernetes-managed objects from Terraform state before `terraform destroy`:

- `module.install_secrets_np`
- `kubernetes_namespace_v1.cni_np_test`

This matches the existing strategy already used for other in-cluster resources such as Argo CD and the baseline secrets module.

## Expected destroy sequence

1. Run `terraform state rm` for Kubernetes resources that only exist inside the cluster.
2. Delete local readiness markers under `artifacts/`.
3. Execute `terraform destroy -auto-approve` for the remaining infrastructure.

## Operational note

This change is meant for teardown scenarios where the cluster lifecycle is shorter than the Terraform state lifecycle. If the cluster is still alive and you want Terraform to destroy in-cluster resources explicitly, run `terraform destroy` before tearing down the API server.