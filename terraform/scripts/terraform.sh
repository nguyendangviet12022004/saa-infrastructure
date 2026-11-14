#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  printf 'Usage: %s <dev|staging|prod> <init|validate|plan|apply>\n' "$0" >&2
  printf '       %s fmt\n' "$0" >&2
}

if [[ "${1:-}" == "fmt" ]]; then
  if [[ "$#" -ne 1 ]]; then
    usage
    exit 2
  fi
  exec terraform -chdir="$project_root" fmt -recursive
fi

if [[ "$#" -ne 2 ]]; then
  usage
  exit 2
fi

environment="$1"
command="$2"

case "$environment" in
  dev|staging|prod) ;;
  *)
    printf 'Error: environment must be dev, staging, or prod (got "%s").\n' "$environment" >&2
    exit 2
    ;;
esac

environment_dir="$project_root/environments/$environment"
if [[ ! -d "$environment_dir" ]]; then
  printf 'Error: environment directory does not exist: %s\n' "$environment_dir" >&2
  exit 1
fi

case "$command" in
  init)
    exec terraform -chdir="$environment_dir" init -input=false
    ;;
  validate)
    exec terraform -chdir="$environment_dir" validate
    ;;
  plan)
    exec terraform -chdir="$environment_dir" plan -out=tfplan
    ;;
  apply)
    if [[ ! -f "$environment_dir/tfplan" ]]; then
      printf 'Error: no saved plan at %s. Run the plan command first.\n' "$environment_dir/tfplan" >&2
      exit 1
    fi
    exec terraform -chdir="$environment_dir" apply tfplan
    ;;
  *)
    printf 'Error: unsupported command "%s".\n' "$command" >&2
    usage
    exit 2
    ;;
esac
