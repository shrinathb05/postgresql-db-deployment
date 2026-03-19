pipeline {
    agent {label 'postgres'}

    parameters {
        string(name: 'TAG_NAME', defaultValue: 'v0.1', description: 'Git tag to deploy')
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
    }
}