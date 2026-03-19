#!/bin/bash
DB_HOST=$1
DB_USER=$2
DB_PASS=$3
DB_NAME=$4
SQL_FILE=$5

set -uo pipefail

LOG_DIR="/home/ubuntu/var/work/logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${LOG_DIR}/pg_${SQL_FILE%.sql}_${TIMESTAMP}.log"

# --- The -f check you requested ---
if [ ! -f "$SQL_FILE" ]; then
    echo "NOTICE: File '$SQL_FILE' not found. Skipping execution." | tee -a "$LOG_FILE"
    exit 0
fi

echo "===== Starting Postgres Execution: $SQL_FILE =====" | tee -a "$LOG_FILE"
echo "Target: $DB_NAME @ $DB_HOST" | tee -a "$LOG_FILE"

# Security: Export Password for psql
export PGPASSWORD="$DB_PASS"

# Run PSQL with --echo-all to see the code and results in logs
psql --echo-all -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -f "$SQL_FILE" --echo-all >> "$LOG_FILE" 2>&1
EXIT_CODE=$?

unset PGPASSWORD

if [ $EXIT_CODE -eq 0 ]; then
    echo "SUCCESS: $SQL_FILE executed perfectly." | tee -a "$LOG_FILE"
    exit 0
else
    echo "ERROR: $SQL_FILE failed with exit code $EXIT_CODE." | tee -a "$LOG_FILE"
    exit $EXIT_CODE
fi