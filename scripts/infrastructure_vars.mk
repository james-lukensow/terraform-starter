
SETTINGS_FILE=$(ROOTDIR)/settings.json

PROJECT_PREFIX=`jq -r .projectPrefix $(SETTINGS_FILE)`
PRIMARY_REGION=`jq -r .primaryRegion $(SETTINGS_FILE)`
TF_STATE_BUCKET=`jq -r .stateBucket $(SETTINGS_FILE)`
TF_STATE_KEY=$(PROJECT_PREFIX)_$(ENV).tfstate