# Root App-of-Apps: gestiona solo apps/metrics (métricas + monitoring)
# Los apps de tests CNI se gestionan directamente por Terraform (abajo)
# para que el overlay correcto se active según cni_provider.
resource "kubernetes_manifest" "argocd_root_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = var.argocd_root_app_name
      namespace = var.argocd_namespace
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
      labels = {
        "app.kubernetes.io/managed-by" = "terraform"
      }
    }
    spec = {
      project = "default"

      source = {
        repoURL        = var.argocd_root_repo_url
        targetRevision = var.argocd_root_repo_revision
        path           = "apps/metrics"
        directory = {
          recurse = true
        }
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.argocd_namespace
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }
}

# App de benchmarks de red (iperf3 + latencia) usando overlay CNI-específico.
# El overlay inyecta CNI_NAME en el ConfigMap cni-results-git-config.
resource "kubernetes_manifest" "cni_test_iperf_app" {
  depends_on = [kubernetes_manifest.argocd_root_app]
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "cni-test-iperf"
      namespace = var.argocd_namespace
      annotations = {
        "argocd.argoproj.io/sync-wave" = "2"
      }
    }
    spec = {
      project = "default"

      source = {
        repoURL        = var.argocd_root_repo_url
        targetRevision = var.argocd_root_repo_revision
        path           = "overlays/cni/${var.cni_provider}"
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "cni-test"
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true",
          "ServerSideApply=true"
        ]
      }
    }
  }
}

# App de exportación de recursos (CPU/Mem desde Prometheus).
# Lee CNI_NAME del mismo ConfigMap que gestiona cni_test_iperf.
resource "kubernetes_manifest" "cni_resource_exporter_app" {
  depends_on = [kubernetes_manifest.argocd_root_app]
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "cni-resource-exporter"
      namespace = var.argocd_namespace
      annotations = {
        "argocd.argoproj.io/sync-wave" = "2"
      }
    }
    spec = {
      project = "default"

      source = {
        repoURL        = var.argocd_root_repo_url
        targetRevision = var.argocd_root_repo_revision
        path           = "grafana-exporter"
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "cni-test"
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true",
          "ServerSideApply=true"
        ]
      }
    }
  }
}

# App de pruebas de Network Policies. Solo se crea cuando:
#   1. El CNI soporta NetworkPolicies (no Flannel)
#   2. Se especifica un caso de uso activo (cni_np_use_case != "")
# El path selecciona el overlay CNI+use-case correcto, que incluye:
#   - base: namespace, demo app, iperf server, CronJobs de benchmark
#   - use-case-N: NetworkPolicies del caso activo
#   - overlay CNI: diferenciadores (CiliumNP L7, Antrea Tiers)
resource "kubernetes_manifest" "cni_np_test_app" {
  count = (var.cni_provider != "flannel" && var.cni_np_use_case != "") ? 1 : 0

  depends_on = [kubernetes_manifest.cni_test_iperf_app]
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "cni-np-test"
      namespace = var.argocd_namespace
      annotations = {
        "argocd.argoproj.io/sync-wave" = "3"
      }
    }
    spec = {
      project = "default"

      source = {
        repoURL        = var.argocd_root_repo_url
        targetRevision = var.argocd_root_repo_revision
        path           = "network_policies/overlays/${var.cni_provider}/${var.cni_np_use_case}"
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "cni-np-test"
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true",
          "ServerSideApply=true"
        ]
      }
    }
  }
}
