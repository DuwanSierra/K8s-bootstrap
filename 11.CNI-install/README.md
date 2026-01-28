# Instalación de CNI con Kustomize

Este directorio contiene configuraciones de [Kustomize](https://kustomize.io/) para instalar los distintos CNI que se pueden usar con el clúster K3s desplegado en DigitalOcean. Cada subcarpeta apunta a los manifiestos oficiales del proyecto correspondiente y aplica parches mínimos para alinearlos con la red por defecto de K3s (`10.42.0.0/16` para los pods y `10.43.0.0/16` para los servicios).

## Estructura

- `Antrea/`
- `Calico/`
- `Cilium/`
- `Flannel/`
- `Makefile`

Dentro de cada carpeta encontrarás:

- `kustomization.yaml`: referencia al manifiesto oficial y definición de parches.
- `patches/`: ajustes de red o parámetros propios del CNI.
- `README.md`: instrucciones específicas y flags relevantes.

## Uso rápido

1. Asegúrate de haber creado el clúster con `flannel_backend = "none"` para evitar conflictos.
2. Posiciónate en este directorio: `cd 11.CNI-install`.
3. Exporta la variable `CNI` con la opción deseada (`Antrea`, `Calico`, `Cilium`, `Flannel`).
4. Aplica la instalación con el Makefile o directamente con `kubectl`.

```bash
# Ejemplos
echo "Aplicando Calico"
CNI=Calico make apply

# Previsualizar el manifiesto renderizado
CNI=Cilium make kustomize > /tmp/cilium.yaml

# Eliminar un despliegue
CNI=Flannel make delete
```

## Personalización de CIDR

Si tu clúster usa rangos distintos a los predeterminados de K3s, modifica los valores en los parches dentro de cada carpeta (`patches/*.yaml`). No olvides versionar esos cambios para mantener la trazabilidad.
