.PHONY: init fmt fmt-diff validate test tflint checkov ci

ci: fmt validate test tflint checkov

init:
	terraform init -backend=false

fmt:
	terraform fmt -recursive -diff

validate: init
	terraform validate

test: init
	terraform test

tflint:
	tflint --init && tflint --recursive

checkov:
	checkov -d .
