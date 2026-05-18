pipeline {

    agent {
        docker {
            image 'sumit1418/sumit-jenkins-agent:latest'
            args '-u root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {

        IMAGE_NAME = "sumit1418/flask-app:latest"

        PROD_SERVER = "13.206.142.132"

        SCANNER_HOME = tool 'sonar-scanner'
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

                sh 'pip install -r requirements.txt'

                sh 'pip install pytest flake8'
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

                    sh '''
                    $SCANNER_HOME/bin/sonar-scanner \
                    -Dsonar.projectKey=jenkins-cicd \
                    -Dsonar.projectName=jenkins-cicd \
                    -Dsonar.sources=. \
                    -Dsonar.host.url=http://13.233.77.203:9000
                    '''
                }
            }
        }

        stage('Build Docker Image') {

            steps {

                sh 'docker build -t $IMAGE_NAME .'
            }
        }

        stage('Push Docker Image') {

            steps {

                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {

                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin

                    docker push $IMAGE_NAME
                    '''
                }
            }
        }

        stage('Deploy To Production') {

            steps {

                sshagent(credentials: ['prod-server-key']) {

                    sh '''
                    ssh -o StrictHostKeyChecking=no ec2-user@$PROD_SERVER "

                    docker pull $IMAGE_NAME

                    docker rm -f flask-app || true

                    docker run -dit \
                    --name flask-app \
                    -p 80:80 \
                    $IMAGE_NAME
                    "
                    '''
                }
            }
        }
    }

    post {

        success {

            echo 'Enterprise CI/CD Pipeline Completed Successfully!'
        }

        failure {

            echo 'Pipeline Failed!'
        }

        always {

            cleanWs()
        }
    }
}
