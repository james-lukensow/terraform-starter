SHELL=/bin/bash
.EXPORT_ALL_VARIABLES:
.SHELLFLAGS = -uec
.PHONY: deploy \
	destroy \
	deploy-lambda \
	deploy-lambdas \
	shared \
	clean \
	destroy \
	deploy-api

shared:
	make -C shared build

deploy: shared
	make -C infrastructure deploy
	make -C infrastructure get-infrastructure-output	
	make -C api deploy
	make -C lambda deploy-lambdas

deploy-api:
	make -C infrastructure get-infrastructure-output
	make -C api deploy

# Deployes a single lambda functions (infrastructure is assumed to have been deployed)
# This target should be called in the following way:
# LAMBDA=myLambdaName make deploy-lambda
deploy-lambda:
	make -C infrastructure get-infrastructure-output
	make -C lambda deploy-lambda

# Deployes all lambda functions (infrastructure is assumed to have been deployed)
deploy-lambdas:
	make -C infrastructure get-infrastructure-output
	make -C lambda deploy-lambdas

destroy: shared
	make -C infrastructure destroy

clean:
	git clean -fdX

