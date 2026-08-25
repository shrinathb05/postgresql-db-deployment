#!/bin/bash
set -uo pipefail

DB_HOST="$1"
DB_USER="$2"
DB_NAME="$3"
SQL_FILE="$4"

if [ -z "${DB_PASS:-}" ]; then
    echo "ERROR: DB_PASS environment variable is not set."
    exit 1
fi

# Permanent log directory for PostgreSQL
PERM_LOG_DIR="/home/ubuntu/logs/postgres"
mkdir -p "$PERM_LOG_DIR"

# Staging workspace directory for Jenkins email attachments
BUILD_LOG_DIR="./build_logs"
mkdir -p "$BUILD_LOG_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BASE_SQL_NAME=$(basename "$SQL_FILE" .sql)
LOG_FILENAME="${DB_NAME}_${BASE_SQL_NAME}_${TIMESTAMP}.log"
PERM_LOG_FILE="${PERM_LOG_DIR}/${LOG_FILENAME}"
BUILD_LOG_FILE="${BUILD_LOG_DIR}/${LOG_FILENAME}"

if [ ! -f "$SQL_FILE" ]; then
    echo "ERROR: SQL File '$SQL_FILE' not found in $(pwd)" | tee "$PERM_LOG_FILE"
    cp "$PERM_LOG_FILE" "$BUILD_LOG_FILE" 2>/dev/null || true
    exit 1
fi

echo "================ PostgreSQL Execution Summary ================" | tee "$PERM_LOG_FILE"
echo "Execution Time: $(date '+%Y-%m-%d %H:%M:%S %Z')" | tee -a "$PERM_LOG_FILE"
echo "Target Host:    $DB_HOST" | tee -a "$PERM_LOG_FILE"
echo "Database:       $DB_NAME" | tee -a "$PERM_LOG_FILE"
echo "SQL Script:     $SQL_FILE" | tee -a "$PERM_LOG_FILE"
echo "Log File:       $PERM_LOG_FILE" | tee -a "$PERM_LOG_FILE"
echo "==============================================================" | tee -a "$PERM_LOG_FILE"

# Export password safely for psql
export PGPASSWORD="$DB_PASS"

# Execute SQL script with ON_ERROR_STOP=1 so failures trigger non-zero exit codes
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f "$SQL_FILE" >> "$PERM_LOG_FILE" 2>&1
EXIT_CODE=$?

unset PGPASSWORD

# Mirror log to workspace staging folder for email & artifact archiving
cp "$PERM_LOG_FILE" "$BUILD_LOG_FILE"

if [ $EXIT_CODE -eq 0 ]; then
    echo "SUCCESS: $SQL_FILE executed successfully." | tee -a "$PERM_LOG_FILE"
    echo "--- LOG OUTPUT ---"
    cat "$PERM_LOG_FILE"
    exit 0
else
    echo "ERROR: $SQL_FILE failed with exit code $EXIT_CODE." | tee -a "$PERM_LOG_FILE"
    echo "--- ERROR LOG OUTPUT ---"
    cat "$PERM_LOG_FILE"
    exit $EXIT_CODE
fi