pipeline {
    agent {label 'node1'}
    
    environment {
        GIT_REPO = "https://github.com/shrinathb05/postgresql-db-deployment.git"
        WORK_DIR = "/home/ubuntu/var/work/postgres"
    }
    
    stages {
        stage('Clean & Setup') {
            steps {
                sh """
                    mkdir -p '${WORK_DIR}'
                    rm -rf '${WORK_DIR}/*'
                """
            }
        }
        
        stage('Checkout Git Tag') {
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
                        credentialsId: 'postgres_creds', // Make sure this ID exists in Jenkins Credentials
                        usernameVariable: 'DB_USER', 
                        passwordVariable: 'DB_PASS'
                    )]) {
                        script {
                            // Validation Check for the DB_HOST
                            if(params.DB_HOST == null || params.DB_HOST == "" ) {
                                error "DB_HOST is null! Please select a Database Server in the parameters."
                            }
                            echo "====== STARTING POSTGRES BACKUP ======"
                            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                if (params.BACKUP_SCRIPT == "" || params.BACKUP_SCRIPT == "none") {
                                    echo "No backup name provided. Forcing failure to meet requirement..."
                                    sh "exit 1" // This forces the stage to fail
                                } else {
                                    sh "bash run_postgres.sh ${params.DB_HOST} \$DB_USER \$DB_PASS ${params.DB_NAME} ${params.BACKUP_SCRIPT}"
                                }
                            }
                        }
                    }
                }
            }
        }
        
        stage('Execute') {
            steps {
                dir("${WORK_DIR}") {
                    withCredentials([usernamePassword(
                        credentialsId: 'postgres_creds', // Make sure this ID exists in Jenkins Credentials
                        usernameVariable: 'DB_USER', 
                        passwordVariable: 'DB_PASS'
                    )]) {
                        script {
                            // Validation Check for the DB_HOST
                            if(params.DB_HOST == null || params.DB_HOST == "" ) {
                                error "DB_HOST is null! Please select a Database Server in the parameters."
                            }
                            echo "====== STARTING POSTGRES EXECUTION OF SCRIPTS ======"
                            sh "bash run_postgres.sh ${params.DB_HOST} \$DB_USER \$DB_PASS ${params.DB_NAME} ${params.EXECUTE_SCRIPT}"
                        }
                    }
                }
            }
        }
        
        stage('Cleanup After deployment') {
            steps {
                    sh "rm -rf '${WORK_DIR}/*'"
            }
        }
    }
}