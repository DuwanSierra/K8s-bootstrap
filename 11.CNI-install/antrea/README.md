# Antrea + Kustomize

La instalación utiliza el manifiesto oficial `antrea.yml` (v1.14.0). El parche incluido actualiza el `ConfigMap` principal para alinear el modo de encapsulación y los CIDR de K3s.

## Pasos

```bash
cd 11.CNI-install
CNI=Antrea make apply
```

## Parámetros relevantes

- `trafficEncapMode`: definido en `patches/antrea-agent-config.yaml`.
- `serviceCIDR`: ajusta el bloque de servicios si tu clúster no usa `10.43.0.0/16`.
- Para cambiar el CIDR de pods añade `clusterCIDR` en el mismo parche.

## Verificación

```bash
kubectl -n kube-system get pods -l app=antrea
kubectl get nodes -o wide | grep Antrea
```
