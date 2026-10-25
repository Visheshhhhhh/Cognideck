pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub-credentials'
        DOCKER_IMAGE_NAME = 'visheshshah20/cognideck'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code from SCM...'
                checkout scm
            }
        }

        stage('Code Validation') {
            steps {
                echo 'Validating application static assets and structure...'
                sh '''
                    test -f index.html || (echo "Missing index.html" && exit 1)
                    test -f styles.css || (echo "Missing styles.css" && exit 1)
                    test -f script.js || (echo "Missing script.js" && exit 1)
                    echo "Static asset integrity verified."
                '''
            }
        }

        stage('Docker Build') {
            steps {
                echo "Building Docker image: ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}..."
                sh """
                    docker build -t ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} -t ${DOCKER_IMAGE_NAME}:latest .
                """
            }
        }

        stage('Docker Push') {
            steps {
                echo "Authenticating and pushing image to Docker Hub..."
                withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo "\$DOCKER_PASS" | docker login -u "\$DOCKER_USER" --password-stdin
                        docker push ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}
                        docker push ${DOCKER_IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Kubernetes Deployment') {
            steps {
                echo "Deploying Cognideck to Minikube cluster..."
                sh """
                    sed -i "s|DOCKER_IMAGE_PLACEHOLDER|${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}|g" k8s/deployment.yaml
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                    kubectl rollout status deployment/cognideck-deployment --timeout=120s
                """
            }
        }

        stage('Verification') {
            steps {
                echo "Verifying deployment, pods, and service status..."
                sh '''
                    kubectl get deployments -l app=cognideck
                    kubectl get pods -l app=cognideck -o wide
                    kubectl get svc cognideck-service
                    echo "Cognideck deployment verification completed successfully!"
                '''
            }
        }
    }

    post {
        always {
            echo "Pipeline run completed."
            sh 'docker logout || true'
        }
        success {
            echo "Pipeline succeeded! Cognideck is live on Minikube."
        }
        failure {
            echo "Pipeline failed. Please inspect the stage logs above."
        }
    }
}
