pipeline {
    agent any
    stages {
        stage('Clone Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Sumitkalamkar/jenkins_cicd.git'
            }
        }
        stage('Test') {
            steps {
                sh 'pip install -r requirements.txt --break-system-packages'
                sh 'pytest'
                sh 'flake8 .'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t mygfgimg .'
            }
        }
        stage('Deploy') {
            steps {
                sh 'docker rm -f webos || true'
                sh 'docker run -dit --name webos -p 80:80 mygfgimg'
            }
        }
    }
}
