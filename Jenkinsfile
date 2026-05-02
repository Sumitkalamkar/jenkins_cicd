pipeline {
    agent { label 'worker' }

    environment {
        PATH = "/home/ec2-user/.local/bin:${env.PATH}"
    }
    stages {
        stage('Clone Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Sumitkalamkar/jenkins_cicd.git'
            }
        }
        stage('Test') {
            steps {
                sh 'pip3 install -r requirements.txt'
                sh 'pytest test_app.py -v'
                sh 'flake8 . --max-line-length=120 --exclude=.git'
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
    post {
        success { echo 'Pipeline completed successfully!' }
        failure { echo 'Pipeline failed. Check logs above.' }
    }
}
