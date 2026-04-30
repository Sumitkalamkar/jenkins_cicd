pipeline {
    agent any

    stages {

        stage('Clone Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Sumitkalamkar/jenkins_cicd.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                python3 --version || true
                pip3 install -r requirements.txt
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
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
