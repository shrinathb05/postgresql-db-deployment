#!/bin/bash
# ==============================================================================
# Script Name:  run_postgres.sh
# Description:  BFSI-Compliant Database Migration & Log Engine
# Security:     Consumes credentials exclusively via Process Environment Memory
# ==============================================================================

set -euo pipefail

########################################
# Validate Environment Variables
########################################
: "${DB_HOST:?DB_HOST not set}"
: "${DB_USER:?DB_USER not set}"
: "${DB_NAME:?DB_NAME not set}"
: "${PGPASSWORD:?PGPASSWORD not set}"
: "${ENVIRONMENT:?ENVIRONMENT not set}"
: "${RELEASE_TAG:?RELEASE_TAG not set}"

########################################
# Validate Input
########################################
SQL_FILE="${1:-}"

if [[ -z "$SQL_FILE" ]]; then
    echo "ERROR: Missing target SQL script argument." >&2
    echo "Usage: $0 <migration_file.sql>" >&2
    exit 1
fi

if [[ ! -f "$SQL_FILE" ]]; then
    echo "ERROR: SQL file does not exist: $SQL_FILE" >&2
    exit 1
fi

if [[ "${SQL_FILE##*.}" != "sql" ]]; then
    echo "ERROR: Only .sql files are allowed" >&2
    exit 1
fi

########################################
# Deployment Metadata & Log Setup
########################################
START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
START_EPOCH=$(date +%s)
RUN_ID=$(date '+%Y%m%d_%H%M%S')

LOG_DIR="reports"
mkdir -p "${LOG_DIR}"

# Distinct log file destinations
BACKUP_LOG="${LOG_DIR}/db_backup_${RUN_ID}.log"
EXECUTE_LOG="${LOG_DIR}/db_execute_${RUN_ID}.log"
HTML_REPORT="${LOG_DIR}/release_report.html"

# Write Initialization details to the Backup/Pre-check Log
{
    echo "===================================="
    echo "Database Pre-Deployment Initialization"
    echo "Environment : ${ENVIRONMENT}"
    echo "Release Tag : ${RELEASE_TAG}"
    echo "Database    : ${DB_NAME}"
    echo "SQL File    : ${SQL_FILE}"
    echo "Start Time  : ${START_TIME}"
    echo "===================================="
} > "${BACKUP_LOG}"

# Initialize Execution Log Header
{
    echo "===================================="
    echo "Database Migration Execution Started"
    echo "Time        : ${START_TIME}"
    echo "SQL File    : ${SQL_FILE}"
    echo "===================================="
} > "${EXECUTE_LOG}"

########################################
# Execute SQL Migration Safely
########################################
STATUS="SUCCESS"

echo "Executing migration script..."
{
    psql \
      -h "${DB_HOST}" \
      -U "${DB_USER}" \
      -d "${DB_NAME}" \
      -v ON_ERROR_STOP=1 \
      -a \
      -f "${SQL_FILE}"
} >> "${EXECUTE_LOG}" 2>&1 || STATUS="FAILED"

########################################
# Capture End Time
########################################
END_TIME=$(date '+%Y-%m-%d %H:%M:%S')
END_EPOCH=$(date +%s)
DURATION=$((END_EPOCH - START_EPOCH))

########################################
# Generate HTML Report
########################################
cat > "${HTML_REPORT}" << EOF
<html>
<head>
<title>Database Deployment Report</title>
<style>
body { font-family: Arial, sans-serif; margin: 30px; }
table { border-collapse: collapse; width: 600px; }
td, th { border: 1px solid #dddddd; padding: 10px; text-align: left; }
th { background-color: #f2f2f2; }
.status-SUCCESS { color: green; font-weight: bold; }
.status-FAILED { color: red; font-weight: bold; }
</style>
</head>
<body>

<h2>Database Deployment Report</h2>

<table>
<tr><th>Property</th><th>Value</th></tr>
<tr><td>Environment</td><td>${ENVIRONMENT}</td></tr>
<tr><td>Release Tag</td><td>${RELEASE_TAG}</td></tr>
<tr><td>Database</td><td>${DB_NAME}</td></tr>
<tr><td>Script</td><td>$(basename "${SQL_FILE}")</td></tr>
<tr><td>Status</td><td><span class="status-${STATUS}">${STATUS}</span></td></tr>
<tr><td>Start Time</td><td>${START_TIME}</td></tr>
<tr><td>End Time</td><td>${END_TIME}</td></tr>
<tr><td>Duration</td><td>${DURATION} seconds</td></tr>
</table>

</body>
</html>
EOF

########################################
# Return Proper Exit Code
########################################
echo ""
echo "Setup/Pre-check Log : ${BACKUP_LOG}"
echo "Execution Log       : ${EXECUTE_LOG}"
echo "HTML Report         : ${HTML_REPORT}"
echo "Deployment Status   : ${STATUS}"

if [[ "${STATUS}" == "FAILED" ]]; then
    exit 1
fi

exit 0

