.PHONY: init plan apply destroy fmt

init:
	terraform init

update:
	terraform get -update

plan:
	terraform plan

apply:
	terraform apply -auto-approve

destroy:
	# Remove k8s-side resources from state — DO destroys them anyway when droplets die
	terraform state rm module.install_secrets[0] || true
	terraform state rm module.install_secrets_np[0] || true
	terraform state rm module.argocd_apps[0] || true
	terraform state rm module.argocd[0] || true
	terraform state rm null_resource.mark_argocd_ready[0] || true
	terraform state rm kubernetes_namespace_v1.cni_np_test[0] || true
	# Drop marker files so next init starts clean
	rm -f artifacts/.argocd_ready artifacts/.kubeconfig_ready
	terraform destroy -auto-approve

fmt:
	terraform fmt -recursive
