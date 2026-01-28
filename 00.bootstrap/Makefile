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
	terraform destroy -auto-approve

fmt:
	terraform fmt -recursive
