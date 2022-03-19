TF_BACKEND = -backend-config "bucket=$(TF_VAR_tf_state_bucket)" -backend-config "region=$(TF_VAR_region)"
TF_BACKEND_KEY = -backend-config "key=$(TF_VAR_sitename)"

.PHONY: init
init:
	cd deploy && \
	terraform init -input=false $(TF_BACKEND) $(TF_BACKEND_KEY) && \
	terraform validate && \
	terraform fmt

.PHONY: plan
plan:
	cd deploy && \
	terraform plan -out=tfplan -input=false

.PHONY: apply_plan
apply_plan:
	cd deploy && \
	terraform apply "tfplan"

.PHONY: apply
apply:
	cd deploy && \
	terraform apply -auto-approve

.PHONY: upload_site
upload_site:
	bash upload.sh

.PHONY: destroy
destroy:
	cd deploy && \
	terraform destroy

.PHONY: destroy_auto
destroy_auto:
	cd deploy && \
	terraform destroy -auto-approve

.PHONY: deploy_site
deploy_site: init plan apply upload_site
