ROOTDIR=..
GLOBAL_SETTINGS_FILE="$(ROOTDIR)/settings.json"
ENV_SETTINGS_FILE="$(ROOTDIR)/config/$(ENV).json"
PLAN_DIR="$(ROOTDIR)/infrastructure/.plan"
PLAN_FILE="$(PLAN_DIR)/tfplan.plan"
PLAN_OUTPUT_FILE="$(PLAN_DIR)/tfplan.json"
OUTPUT_FILE="$(PLAN_DIR)/output.json"

include ../scripts/checkenv.mk
include ../scripts/infrastructure_vars.mk

init:
	terraform init \
		-reconfigure \
		-backend-config "bucket=${TF_STATE_BUCKET}" \
		-backend-config "key=${TF_STATE_KEY}" \
		-backend-config "region=${PRIMARY_REGION}"

plan: init
	mkdir -p ${PLAN_DIR}
	terraform plan \
		-compact-warnings \
		-input=false \
		-var-file="$(GLOBAL_SETTINGS_FILE)" \
		-var-file="$(ENV_SETTINGS_FILE)" \
		-out="$(PLAN_FILE)"
	terraform show -json $(PLAN_FILE) > $(PLAN_OUTPUT_FILE)
	rm -rf $(PLAN_OUTPUT_FILE)

deploy: plan
	terraform apply -compact-warnings -input=false -auto-approve $(PLAN_FILE)

destroy: plan
	terraform destroy \
		-compact-warnings \
		-input=false \
		-auto-approve \
		-var-file="$(GLOBAL_SETTINGS_FILE)" \
		-var-file="$(ENV_SETTINGS_FILE)"

get-infrastructure-output:
	terraform output -json > $(OUTPUT_FILE)
