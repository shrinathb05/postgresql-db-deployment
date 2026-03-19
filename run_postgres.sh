#!/bin/bash
DB_HOST=$1
DB_USER=$2
DB_PASS=$3
DB_NAME=$4
SQL_FILE=$5

# STRICT MODE: 
set -euo pipefail

LOG_DIR="/home/ubuntu/var/work/logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
# Handle cases where SQL_FILE might be empty to avoid naming errors
LOG_FILE="${LOG_DIR}/pg_${SQL_FILE:-unknown}_${TIMESTAMP}.log"

# --- REQUIRED FILE CHECK ---
# Changed 'exit 0' to 'exit 1' because you want the stage to FAIL if the file is missing
if [ ! -f "$SQL_FILE" ]; then
    echo "ERROR: SQL File '$SQL_FILE' not found in $(pwd)" | tee -a "$LOG_FILE"
    exit 1
fi

echo "===== Starting Postgres Execution: $SQL_FILE =====" | tee -a "$LOG_FILE"
echo "Target: $DB_NAME @ $DB_HOST" | tee -a "$LOG_FILE"

# Security: Export Password for psql
export PGPASSWORD="$DB_PASS"

# 1. Added -v ON_ERROR_STOP=1 so psql fails immediately on a bad query
# 2. Removed the double --echo-all (you had it twice)
psql -v ON_ERROR_STOP=1 -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -f "$SQL_FILE" --echo-all >> "$LOG_FILE" 2>&1
EXIT_CODE=$?

unset PGPASSWORD

if [ $EXIT_CODE -eq 0 ]; then
    echo "SUCCESS: $SQL_FILE executed perfectly." | tee -a "$LOG_FILE"
    exit 0
else
    echo "ERROR: $SQL_FILE failed with exit code $EXIT_CODE." | tee -a "$LOG_FILE"
    exit $EXIT_CODE
fi