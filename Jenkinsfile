pipeline {
    agent {label 'postgres'}

    parameters {
        string(name: 'TAG_NAME', defaultValue: 'v0.1', description: 'Git tag to deploy')

        choice(
            name: 'DB_HOST',
            choices: ['98.89.45.210', '10.23.434.554'],
            description: 'Select Database Server'
        )

        choice(
            name: 'DB_NAME',
            choices: ['jenkins', 'postgres'],
            description: 'Select Database Name'
        )
        
        text(
            name: 'BACKUP_SCRIPT',
            defaultValue: '',
            description: 'e.g backup.sql or any file in .sql format'
        )
    }

    environment {
        GIT_REPO = "https://github.com/shrinathb05/postgresql-db-deployment.git"
        WORK_DIR = "home/ubuntu/var/work/postgres"
    }

    stages {
        stage('Clean and Setup') {
            steps {
                sh """
                    mkdir -p '${WORK_DIR}'
                    rm -rf '${WORK_DIR}/*'
                """
            }
        }

        stage('Checkout Tag') {
            steps {
                dir("${WORK_DIR}") {
                    checkout([$class: 'GitSCM',
                        branches: [[name: "refs/tags/${params.TAG_NAME}"]],
                        userRemoteConfigs: [[url: "${env.GIT_REPO}"]]
                    ])
                }
            }
        }
        
        stage('Backup') {
            steps {
                dir("${WORK_DIR}") {
                    withCredentials([usernamePassword(
                        credentialsId: 'postgres-creds', // Make sure this ID exists in Jenkins Credentials
                        usernameVariable: 'DB_USER', 
                        passwordVariable: 'DB_PASS'
                    )]) {
                        script {
                            // Validation Check for the DB_HOST
                            if(params.DB_HOST == null || params.DB_HOST == "" ) {
                                error "DB_HOST is null! Please select a Database Server in the parameters."
                            }
                            echo "====== STARTING POSTGRES BACKUP ======"
                            sh "bash run_postgres.sh ${params.DB_HOST} \$DB_USER \$DB_PASS ${params.DB_NAME} ${params.BACKUP_SCRIPT}"
                        }
                    }
                }  
            }
        }
    }
}