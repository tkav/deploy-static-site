TF_BACKEND = -backend-config "bucket=$(TF_VAR_tf_state_bucket)" -backend-config "region=$(TF_VAR_region)"
TF_BACKEND_KEY = -backend-config "key=$(TF_VAR_sitename)"
TF_DIST_BACKEND_KEY = -backend-config "key=$(TF_VAR_sitename)-distribution"



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

.PHONY: save_outputs
save_outputs:
	cd deploy && \
	terraform output -json > outputs.json

.PHONY: process_outputs
process_outputs:
	cd deploy && \
	cat outputs.json | jq -r '@sh "export CLOUDFRONT_ID=\(.cloudfront_id.value)\nexport ORIGIN_ID=\(.origin_identity_id.value)"' > ../outputs.sh

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
deploy_site: init plan apply save_outputs process_outputs upload_site





.PHONY: distribution_init
distribution_init:
	cd deploy_distribution && \
	terraform init -input=false $(TF_BACKEND) $(TF_DIST_BACKEND_KEY) && \
	terraform validate && \
	terraform fmt

.PHONY: distribution_import
distribution_import:
	cd deploy_distribution && \
	terraform import aws_cloudfront_distribution.website_cdn_root $(CLOUDFRONT_ID) && \
	terraform import aws_cloudfront_origin_access_identity.website_origin_identity $(ORIGIN_ID)

.PHONY: distribution_plan
distribution_plan:
	cd deploy_distribution && \
	terraform plan -out=tfplan -input=false

.PHONY: distribution_apply_plan
distribution_apply_plan:
	cd deploy_distribution && \
	terraform apply "tfplan"

.PHONY: distribution_apply
distribution_apply:
	cd deploy_distribution && \
	terraform apply -auto-approve

.PHONY: distribution_destroy
distribution_destroy:
	cd deploy_distribution && \
	terraform destroy

.PHONY: distribution_destroy_auto
distribution_destroy_auto:
	cd deploy_distribution && \
	terraform destroy -auto-approve

.PHONY: update_distribution
update_distribution: distribution_init distribution_import distribution_plan distribution_apply





.PHONY: destroy_all
destroy_all: destroy_auto distribution_destroy_auto