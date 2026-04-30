pipeline {
    agent any

    stages {

        stage('Clone Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Sumitkalamkar/jenkins_cicd.git'
            }
        }

        stage('Test in Python Container') {
            agent {
                docker {
                    image 'python:3.9'
                }
            }
            steps {
                sh '''
                pip install -r requirements.txt
                pytest
                flake8 .
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t mygfgimg .
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                docker rm -f webos || true
                docker run -dit --name webos -p 80:80 mygfgimg
                '''
            }
        }
    }
}
