# Cilium + Kustomize

Esta carpeta aplica el manifiesto `quick-install.yaml` de Cilium 1.15.5 y parchea el `ConfigMap cilium-config` con parámetros acordes al clúster K3s.

## Despliegue

```bash
cd 11.CNI-install
CNI=Cilium make apply
```

## Parámetros destacados

- `cluster-name` y `cluster-id`: úsalos para distinguir este clúster si tienes malla multi-cluster.
- `ipv4-native-routing-cidr`: debe coincidir con el Pod CIDR real (`10.42.0.0/16` por defecto).
- `kube-proxy-replacement`: deja `strict` si planeas deshabilitar kube-proxy en K3s; cambia a `partial` si aún lo usas.

## Comprobaciones

```bash
kubectl -n kube-system get pods -l k8s-app=cilium
kubectl -n kube-system exec -it ds/cilium -- cilium status
```
