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

# Step 2: Create the Database & User
    Log into the Postgres prompt to set up your credentials.
    sudo -u postgres psql

    -- Create the user
    CREATE USER release WITH PASSWORD 'shrinath';

    -- Create the database
    CREATE DATABASE jenkins;

    -- Grant permissions
    GRANT ALL PRIVILEGES ON DATABASE jenkins TO release;

    -- Exit
    \q

# Step 3: Prepare the Jenkins Agent
    Your Jenkins Agent (node1) needs the PostgreSQL client installed so it can run the psql command.

    