# Step 1: Install & Configure PostgreSQL (On DB Server)

# Run these commands on your target Database Server (e.g., 10.181.63.162).
    - 1. Install PostgreSQL
        Bash

        sudo apt update
        sudo apt install postgresql postgresql-contrib -y

    - 2. Configure Network Access
        By default, Postgres only listens to "localhost." We need to open it to your Jenkins Agent.

        Open the config file: sudo nano /etc/postgresql/$(ls /etc/postgresql/)/main/postgresql.conf

        Find the line: #listen_addresses = 'localhost'

        Change to: listen_addresses = '*'

    - 3. Configure Authentication (The pg_hba file)

        This tells Postgres to allow your Jenkins Agent IP to connect with a password.

        Open: sudo nano /etc/postgresql/$(ls /etc/postgresql/)/main/pg_hba.conf

        Add this line at the very bottom:
        host    all             all             agent_ip/32         md5

    - 4. Restart Postgres
        sudo systemctl restart postgresql


# Step 2: Create the Database & User
    Log into the Postgres prompt to set up your credentials.
    sudo -u postgres psql

    -- Create the user
    CREATE USER user WITH PASSWORD 'password';

    -- Create the database
    CREATE DATABASE jenkins;

    -- Grant permissions
    GRANT ALL PRIVILEGES ON DATABASE jenkins TO release;

    -- Exit
    \q

    # Provide permissions

    -- 1. Grant usage and create permissions on the public schema to your user
    GRANT USAGE, CREATE ON SCHEMA public TO release;

    -- 2. Make the 'release' user the owner of the schema (optional but recommended for a deployment user)
    ALTER SCHEMA public OWNER TO release;

    -- 3. Ensure all future tables created by 'release' are manageable
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO release;

    -- Grant the release user permission to create tables in the public schema
    GRANT ALL ON SCHEMA public TO release;

    -- Ensure the user owns the schema to avoid future permission issues
    ALTER SCHEMA public OWNER TO release;

    -- Exit psql
    \q

# Step 3: Prepare the Jenkins Agent
    Your Jenkins Agent (node1) needs the PostgreSQL client installed so it can run the psql command.

    sudo apt update
    sudo apt install postgresql-client -y

# Step 4: Create the run_postgres.sh Script
    run_postgres.sh
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
    psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -f "$SQL_FILE" --echo-all >> "$LOG_FILE" 2>&1
    EXIT_CODE=$?

    unset PGPASSWORD

    if [ $EXIT_CODE -eq 0 ]; then
        echo "SUCCESS: $SQL_FILE executed perfectly." | tee -a "$LOG_FILE"
        exit 0
    else
        echo "ERROR: $SQL_FILE failed with exit code $EXIT_CODE." | tee -a "$LOG_FILE"
        exit $EXIT_CODE
    fi

# 5 Check the postgreqsl is able access or not from your agent ip
    psql -h db_ip -U user -d database
    -- after prompt enter the password
    OR check using below command
    nc -zv 98.89.45.210 5432

# 6 Setup the jenkins master server
    login into the server

    # Install java
    sudo apt update -y && sudo apt upgrade -y
    sudo apt install fontconfig openjdk-21-jre
    java -version
    sudo apt update
    
    # Installing jenkins visit the official website and install it choose the long term
    sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
    echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null

    sudo apt update
    sudo apt install jenkins

    # Start jenkins
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
    sudo systemctl status jenkins

    # Open the jenkins in browser using the ip and port default port will be 8080
    http://jenkins_master_ip:8080
    first time ask for the password take password from below path and enter into the browser
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    start seleting the install suggested plugins


    # Setup the agent node on jenkins
    generate the ssh key in master jenkins server using below command
    ssh-keygen -t rsa -b 4096
    cd ~/.ssh
    
    # copy the public into the agent server and check the server is accessible or not
    cat id_rsa.pub              --- paste the ke into the agent server in below file
    vim ~/.ssh/authorized_keys  --- paste the copied key into this file 
    sudo systemctl restart ssh  --- restart the ssh in agent server
    ssh ubuntu@agent_ip         --- check the server accessbile or not

    # Go to Manage Jenkins > Nodes (or Manage Nodes and Clouds).
    Click New Node.
        Node Name: node1
        Type: Permanent Agent
    Configure the details:
        Remote root directory: /home/ubuntu
        Labels: db-agent (This matches the label in your Jenkinsfile).
        Launch method: Launch agents via SSH.
        Host: agent_ip
        Credentials: Click Add > Jenkins.
            Kind: SSH Username with private key.    
            ID: agent-ssh-key.
            Username: ubuntu.
            Private Key: Select "Enter directly" and paste the content of your Master's private key (find it on Master at /home/ubuntu/.ssh/id_rsa).
        Host Key Verification Strategy: Select Non verifying Verification Strategy (Common for internal/private networks).
        Save and Launch: Click Save, then click on the node and select Launch Agent.
