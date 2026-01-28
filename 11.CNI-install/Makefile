#!/usr/bin/make -f

CNI ?= Calico
KUBECTL ?= kubectl
KUBE_CONTEXT ?=

KUSTOMIZE_FLAGS :=
ifneq ($(strip $(KUBE_CONTEXT)),)
KUSTOMIZE_FLAGS += --context $(KUBE_CONTEXT)
endif

.PHONY: apply delete kustomize diff

apply:
	@echo "[INFO] Aplicando $(CNI)"
	$(KUBECTL) $(KUSTOMIZE_FLAGS) apply -k $(CNI)

diff:
	$(KUBECTL) $(KUSTOMIZE_FLAGS) diff -k $(CNI)

kustomize:
	$(KUBECTL) $(KUSTOMIZE_FLAGS) kustomize $(CNI)

delete:
	@echo "[INFO] Eliminando $(CNI)"
	$(KUBECTL) $(KUSTOMIZE_FLAGS) delete -k $(CNI)
