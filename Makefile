SHELL=/bin/bash
.EXPORT_ALL_VARIABLES:
.SHELLFLAGS = -uec
.PHONY: deploy \
	destroy \
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

deploy-api:
	make -C infrastructure get-infrastructure-output
	make -C api deploy

destroy: shared
	make -C infrastructure destroy

clean:
	git clean -fdX

