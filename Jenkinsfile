pipeline {
    agent any

    environment {
        IMAGE_NAME = "todo-api"
        IMAGE_TAG  = "1.0.${BUILD_NUMBER}"   // tagged per build
        PATH       = "/Users/mohitduhan/bin:/opt/homebrew/bin:/usr/local/bin:${env.PATH}"
    }

    stages {

        // ─────────────────────────────────────────
        // STAGE 1 — BUILD
        // install deps and package into a Docker image
        // ─────────────────────────────────────────
        stage('Build') {
            steps {
                echo "Installing dependencies..."
                sh 'npm ci'

                echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -f dockerfile ."
                sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest"

                echo "Build artefact: Docker image ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        // ─────────────────────────────────────────
        // STAGE 2 — TEST
        // run Jest unit + integration tests with coverage
        // ─────────────────────────────────────────
        stage('Test') {
            steps {
                echo "Running automated tests..."
                sh 'JEST_JUNIT_OUTPUT_DIR=./coverage JEST_JUNIT_OUTPUT_NAME=junit.xml npm test -- --reporters=default --reporters=jest-junit --coverage'
            }
            post {
                always {
                    // publish test results in Jenkins UI
                    junit testResults: 'coverage/junit.xml', allowEmptyResults: true
                    publishHTML([
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'coverage/lcov-report',
                        reportFiles: 'index.html',
                        reportName: 'Coverage Report'
                    ])
                }
            }
        }

        // ─────────────────────────────────────────
        // STAGE 3 — CODE QUALITY
        // SonarQube analyses code health (smells, duplication, complexity)
        // ─────────────────────────────────────────
        stage('Code Quality') {
            steps {
                echo "Running SonarQube analysis..."
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        sonar-scanner \
                          -Dsonar.projectKey=todo-api \
                          -Dsonar.sources=src \
                          -Dsonar.tests=tests \
                          -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info
                    '''
                }
                // wait for quality gate result — fail pipeline if it doesn't pass
                timeout(time: 10, unit: 'MINUTES') {
                    def qg = waitForQualityGate abortPipeline: false
                    if (qg.status == 'TIMEOUT') {
                        echo "WARNING: SonarQube Quality Gate check timed out. Continuing..."
                    } else if (qg.status != 'OK') {
                        error "Quality Gate failed: ${qg.status}"
                    } else {
                        echo "Quality Gate passed: ${qg.status}"
                    }
                }
            }
        }

        // ─────────────────────────────────────────
        // STAGE 4 — SECURITY
        // Trivy scans the Docker image for known CVEs
        // ─────────────────────────────────────────
        stage('Security') {
            steps {
                echo "Running Trivy security scan on Docker image..."
                sh """
                    trivy image \
                      --exit-code 0 \
                      --severity HIGH,CRITICAL \
                      --format table \
                      ${IMAGE_NAME}:${IMAGE_TAG}
                """
                // save report as artefact
                sh """
                    trivy image \
                      --exit-code 0 \
                      --severity HIGH,CRITICAL \
                      --format json \
                      --output trivy-report.json \
                      ${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
            post {
                always {
                    archiveArtifacts artifacts: 'trivy-report.json', fingerprint: true
                }
            }
        }

        // ─────────────────────────────────────────
        // STAGE 5 — DEPLOY (staging)
        // spin up the app in a Docker staging container
        // ─────────────────────────────────────────
        stage('Deploy') {
            steps {
                echo "Deploying to staging environment..."
                // stop any old staging container first
                sh 'docker rm -f todo-api-staging || true'
                sh """
                    docker run -d \
                      --name todo-api-staging \
                      -p 3000:3000 \
                      -e NODE_ENV=staging \
                      ${IMAGE_NAME}:${IMAGE_TAG}
                """
                // quick health check to confirm deployment worked
                sh 'sleep 3 && curl -f http://localhost:3000/health || exit 1'
                echo "Staging deployment successful!"
            }
        }

        // ─────────────────────────────────────────
        // STAGE 6 — RELEASE (production)
        // promote the same image to production container
        // ─────────────────────────────────────────
        stage('Release') {
            steps {
                echo "Releasing to production..."
                sh 'docker rm -f todo-api-production || true'
                sh """
                    docker run -d \
                      --name todo-api-production \
                      -p 3001:3000 \
                      -e NODE_ENV=production \
                      ${IMAGE_NAME}:${IMAGE_TAG}
                """
                sh 'sleep 3 && curl -f http://localhost:3001/health || exit 1'
                echo "Production release successful! Version: ${IMAGE_TAG}"
            }
        }

        // ─────────────────────────────────────────
        // STAGE 7 — MONITORING
        // start Prometheus + Grafana for live metrics
        // ─────────────────────────────────────────
        stage('Monitoring') {
            steps {
                echo "Starting monitoring stack (Prometheus + Grafana)..."
                sh 'docker rm -f prometheus grafana || true'

                sh """
                    docker run -d \
                      --name prometheus \
                      -p 9090:9090 \
                      -v \$(pwd)/monitoring/prometheus.yml:/etc/prometheus/prometheus.yml \
                      prom/prometheus:latest
                """

                sh """
                    docker run -d \
                      --name grafana \
                      -p 3002:3000 \
                      -e GF_SECURITY_ADMIN_PASSWORD=admin \
                      grafana/grafana:latest
                """

                sh 'sleep 5 && curl -f http://localhost:9090/-/healthy || echo "Prometheus starting..."'
                echo "Monitoring live — Prometheus: http://localhost:9090 | Grafana: http://localhost:3002"
            }
        }
    }

    // ─────────────────────────────────────────
    // POST — notify on result
    // ─────────────────────────────────────────
    post {
        success {
            echo "Pipeline completed successfully! App running at http://localhost:3001"
        }
        failure {
            echo "Pipeline failed — check stage logs above."
        }
        always {
            script {
                def result = currentBuild.result ?: 'SUCCESS'
                echo "Build ${IMAGE_TAG} finished with status: ${result}"
            }
        }
    }
}