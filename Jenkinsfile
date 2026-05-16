pipeline {
    agent { label 'worker' }

    tools {
        sonarQube 'sonar-scanner'
    }

    environment {
        PATH = "/home/ec2-user/.local/bin:${env.PATH}"
    }

    stages {

        stage('Clone Code') {
            steps {
                git branch: 'main',
                url: 'https://github.com/Sumitkalamkar/jenkins_cicd.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'pip3 install -r requirements.txt'
                sh 'pip3 install pytest flake8'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'pytest test_app.py -v'
            }
        }

        stage('Flake8 Lint Check') {
            steps {
                sh 'flake8 . --max-line-length=120 --exclude=.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh 'sonar-scanner'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t mygfgimg .'
            }
        }

        stage('Deploy Container') {
            steps {
                sh 'docker rm -f webos || true'
                sh 'docker run -dit --name webos -p 80:80 mygfgimg'
            }
        }
    }

    post {

        success {
            echo 'Pipeline completed successfully!'
        }

        failure {
            echo 'Pipeline failed. Check logs above.'
        }

        always {
            cleanWs()
        }
    }
}
