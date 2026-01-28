# Calico + Kustomize

Se referencia el manifiesto oficial `calico.yaml` (v3.27.3) y se inyectan variables de entorno sobre el `DaemonSet calico-node` para alinear los CIDR de K3s.

## Despliegue

```bash
cd 11.CNI-install
CNI=Calico make apply
```

## Campos clave

- `CALICO_IPV4POOL_CIDR`: ajusta el rango de pods si difiere de `10.42.0.0/16`.
- `CALICO_IPV4POOL_IPIP`: define si se usa IP-in-IP (`Always`, `CrossSubnet`, `Never`).
- `IP_AUTODETECTION_METHOD`: puede cambiarse a `interface=eth0` o cualquier modo soportado.

Modifica `patches/calico-node-env-patch.yaml` para actualizar estos valores.

## Validación rápida

```bash
kubectl -n kube-system get pods -l k8s-app=calico-node
kubectl get felixconfigurations default -o yaml | grep -i cidr -n
```
