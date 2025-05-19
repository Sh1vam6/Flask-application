pipeline {
    agent any

    environment {
        IMAGE_NAME = 'sh1vam6/flask-application:latest'
        CONTAINER_NAME = 'flask-application'
        EMAIL_RECIPIENTS = 'peakyjohn526@gmial.com'
    }

    stages {

        stage('Set up Python Environment') {
            steps {
                sh '''
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install --upgrade pip
                    pip install -e .[dev]
                '''
            }
        }

        stage('Run Tests') {
            steps {
                sh '''
                    . venv/bin/activate
                    pytest
                '''
            }
        }

        stage('Code Quality Check (flake8)') {
            steps {
                sh '''
                    . venv/bin/activate
                    pip install flake8
                    flake8 flaskr tests
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${IMAGE_NAME}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${IMAGE_NAME}
                    '''
                }
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true
                    docker run -d -p 5000:5000 --name ${CONTAINER_NAME} ${IMAGE_NAME}
                '''
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                    sleep 5
                    curl --fail http://localhost:5000 || echo "App is not responding"
                '''
            }
        }
    }

    post {
        success {
            mail to: "${EMAIL_RECIPIENTS}",
                 subject: "Jenkins Job Success: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                 body: "The Jenkins job completed successfully.\n\nURL: ${env.BUILD_URL}"
        }

        failure {
            mail to: "${EMAIL_RECIPIENTS}",
                 subject: "Jenkins Job FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                 body: "The Jenkins job failed.\n\nURL: ${env.BUILD_URL}"
        }
    }
}
