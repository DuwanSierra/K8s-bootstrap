# Flannel + Kustomize

Se usa el manifiesto upstream `kube-flannel.yml` (v0.24.2) y se reemplaza el `ConfigMap kube-flannel-cfg` para usar el rango típico de K3s.

## Despliegue

```bash
cd 11.CNI-install
CNI=Flannel make apply
```

## Ajustes

- `net-conf.json`: define el CIDR (`Network`) y el backend (`vxlan`).
- `cni-conf.json`: puedes añadir plugins secundarios como `bandwidth` o cambiar el nombre del bridge.

## Comprobaciones

```bash
kubectl -n kube-system get pods -l app=flannel
kubectl get cm kube-flannel-cfg -n kube-system -o jsonpath='{.data.net-conf\.json}'
```
