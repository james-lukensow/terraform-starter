NPX = npm config set unsafe-perm true && npx --no-install

node_modules: package.json
	npm i
	touch $@

shared:
	make -C ../shared build

build: node_modules shared
	${NPX} webpack

# This target should be called in the following way:
# LAMBDA=myLambdaName make deploy-lambda
deploy-lambda: build
	/bin/bash ../scripts/deploy-lambda.sh $$LAMBDA

deploy-lambdas: build
	/bin/bash ../scripts/deploy-lambdas.sh
	