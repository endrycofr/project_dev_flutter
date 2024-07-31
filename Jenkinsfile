pipeline {
    agent any
    stages {
        stage('Clone repository') {
            steps {
                git 'https://github.com/endrycofr/project_dev_flutter.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("endrycofr/project_deploy")
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-credentials') {
                        dockerImage.push("latest")
                    }
                }
            }
        }
    }
}
