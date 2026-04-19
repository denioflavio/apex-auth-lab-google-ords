#!/usr/bin/env bash

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${PROJECT_DIR}/.env.local"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing .env.local. Copy .env.local.example and fill in the values first."
  exit 1
fi

set -a
source "${ENV_FILE}"
set +a

if [[ "${DB_USER}" == "CHANGE_ME" || "${DB_PASSWORD}" == "CHANGE_ME" ]]; then
  echo "Update DB_USER and DB_PASSWORD in .env.local before running this script."
  exit 1
fi

if [[ ! -d "${TNS_ADMIN}" ]]; then
  echo "Wallet directory not found: ${TNS_ADMIN}"
  exit 1
fi

if [[ ! -x "${SQLCL_BIN}" ]]; then
  echo "SQLcl binary not found or not executable: ${SQLCL_BIN}"
  exit 1
fi

export TNS_ADMIN
export JAVA_HOME
export PATH="${JAVA_HOME}/bin:$(dirname "${SQLCL_BIN}"):${PATH}"

run_script() {
  local script_path="$1"
  echo
  echo "==> Running ${script_path}"
  "${SQLCL_BIN}" "${DB_USER}/${DB_PASSWORD}@${DB_TNS_ALIAS}" @"${script_path}"
}

case "${1:-all}" in
  test)
    "${SQLCL_BIN}" "${DB_USER}/${DB_PASSWORD}@${DB_TNS_ALIAS}"
    ;;
  tables)
    run_script "${PROJECT_DIR}/sql/01_tables.sql"
    ;;
  packages)
    run_script "${PROJECT_DIR}/sql/02_packages.sql"
    ;;
  ords)
    run_script "${PROJECT_DIR}/sql/03_ords_rest.sql"
    ;;
  apex-helpers)
    run_script "${PROJECT_DIR}/sql/04_apex_helpers.sql"
    ;;
  checks)
    run_script "${PROJECT_DIR}/sql/06_test_calls.sql"
    ;;
  all)
    run_script "${PROJECT_DIR}/sql/01_tables.sql"
    run_script "${PROJECT_DIR}/sql/02_packages.sql"
    run_script "${PROJECT_DIR}/sql/03_ords_rest.sql"
    run_script "${PROJECT_DIR}/sql/04_apex_helpers.sql"
    ;;
  *)
    echo "Usage: ./run_sqlcl.sh [test|tables|packages|ords|apex-helpers|checks|all]"
    exit 1
    ;;
esac
