.PHONY: init fmt fmt-diff validate test checkov ci

ci: fmt validate test checkov

init:
	terraform init -backend=false

fmt:
	terraform fmt -recursive -diff

validate: init
	terraform validate

test: init
	terraform test

checkov:
	checkov -d . \
	  --framework terraform \
	  --download-external-modules true
