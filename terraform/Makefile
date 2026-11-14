.PHONY: help init fmt validate plan apply

ENV ?= dev

help:
	@printf 'Targets:\n'
	@printf '  make init ENV=dev|staging|prod\n'
	@printf '  make fmt\n'
	@printf '  make validate ENV=dev|staging|prod\n'
	@printf '  make plan ENV=dev|staging|prod\n'
	@printf '  make apply ENV=dev|staging|prod  (applies the saved tfplan)\n'

init:
	@./scripts/terraform.sh "$(ENV)" init

fmt:
	@./scripts/terraform.sh fmt

validate:
	@./scripts/terraform.sh "$(ENV)" validate

plan:
	@./scripts/terraform.sh "$(ENV)" plan

apply:
	@./scripts/terraform.sh "$(ENV)" apply
