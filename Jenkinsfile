pipeline {
    agent any
    stages {
        stage('Clone Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Sumitkalamkar/jenkins_cicd.git'
            }
        }
        stage('Debug') {
            steps {
                sh 'echo "Workspace = $WORKSPACE"'
                sh 'ls -la $WORKSPACE'
            }
        }
        stage('Test') {
            steps {
                sh 'docker run --rm -v $WORKSPACE:/app -w /app python:3.9 pip install -r requirements.txt'
                sh 'docker run --rm -v $WORKSPACE:/app -w /app python:3.9 pytest'
                sh 'docker run --rm -v $WORKSPACE:/app -w /app python:3.9 flake8 .'
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
