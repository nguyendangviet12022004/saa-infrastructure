.PHONY: help tf-init tf-fmt tf-validate tf-plan tf-apply tf-purge-history

ENV ?= dev
FILE ?=

help:
	@printf 'Targets:\n'
	@printf '  make tf-init ENV=dev|staging|prod\n'
	@printf '  make tf-fmt\n'
	@printf '  make tf-validate ENV=dev|staging|prod\n'
	@printf '  make tf-plan ENV=dev|staging|prod\n'
	@printf '  make tf-apply ENV=dev|staging|prod  (applies the saved tfplan)\n'
	@printf '  make tf-purge-history FILE=<repository-relative-path>\n'

tf-init:
	@./scripts/terraform.sh "$(ENV)" init

tf-fmt:
	@./scripts/terraform.sh fmt

tf-validate:
	@./scripts/terraform.sh "$(ENV)" validate

tf-plan:
	@./scripts/terraform.sh "$(ENV)" plan

tf-apply:
	@./scripts/terraform.sh "$(ENV)" apply

tf-purge-history:
	@test -n "$(FILE)" || { printf 'Usage: make tf-purge-history FILE=<repository-relative-path>\n' >&2; exit 2; }
	@./scripts/purge-file-from-history.sh "$(FILE)"
