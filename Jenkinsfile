pipeline {
    agent any

    tools {
        jdk 'jdk17'
        maven 'maven3'
    }
    environment {
        SCANNER_HOME= tool 'sonar-scanner'
        AWS_ACCESS_KEY_ID = credentials('aws-creds')
        AWS_SECRET_ACCESS_KEY = credentials('aws-creds')
    }
    
    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', credentialsId: 'git-cred', url: 'https://github.com/Ngozi-N/fullstack-blogging-application.git'
            }
        }
        
        stage('Compile') {
            steps {
                sh "mvn compile"
            }
        }
        
        stage('Test') {
            steps {
                sh "mvn test"
            }
        }
        
        stage('Trivy FS Scan') {
            steps {
                sh "trivy fs --format table -o fs.html ."
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                sh '''$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Blogging-application -Dsonar.projectKey=Blogging-application \
                      -Dsonar.java.binaries=target'''
                }
            }
        }
        
        stage('Build') {
            steps {
                sh "mvn clean package spring-boot:repackage -DskipTests"
            }
        }
        
        stage('Publish Artifacts') {
            steps {
                withMaven(globalMavenSettingsConfig: 'maven-settings', jdk: 'jdk17', maven: 'maven3', mavenSettingsConfig: '', traceability: true) {
                    sh "mvn deploy"
                }
            }
        }
        
        stage('Quick File Confirm') {
            steps {
                sh "ls -lh target/"
            }
        }
        
        stage('Docker Build & Tag') {
            steps {
                script {
                withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                    sh "docker build -t <docker_username>/blogging-application:latest ."
                }
                }
            }
        }
        
        stage('Trivy Image Scan') {
            steps {
                sh "trivy image --format table -o image.html <docker_username>/blogging-application:latest"
            }
        }
        
        stage('Docker Push Image') {
            steps {
                script {
                withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                    sh "docker push <docker_username>/blogging-application:latest"
                }
                }
            }
        }
        
        stage('K8s-Deploy') {
            steps {
                withKubeConfig(credentialsId: 'k8s-cred1') {
                    sh "kubectl apply -f deployment-service.yml"
                    sleep 20
                }
            }
        }
        
        stage('Verify the Deployment') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'bloggingapplication-cluster', contextName: '', credentialsId: 'k8s-cred1', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://40991FE2BFC52C16710103E99F31C24A.gr7.eu-west-2.eks.amazonaws.com') {
                    sh "kubectl get pods"
                    sh "kubectl get svc"
                }
            }
        }
    }
    post {
    always {
        script {
            def jobName = env.JOB_NAME
            def buildNumber = env.BUILD_NUMBER
            def pipelineStatus = currentBuild.result ?: 'UNKNOWN'
            def bannerColor = pipelineStatus.toUpperCase() == 'SUCCESS' ? 'green' : 'red'
    
            def body = """
                <html>
                <body>
                <div style="border: 4px solid ${bannerColor}; padding: 10px;">
                <h2>${jobName} - Build ${buildNumber}</h2>
                <div style="background-color: ${bannerColor}; padding: 10px;">
                <h3 style="color: white;">Pipeline Status: ${pipelineStatus.toUpperCase()}</h3>
                </div>
                <p>Check the <a href="${BUILD_URL}">console output</a>.</p>
                </div>
                </body>
                </html>
            """

            emailext (
                subject: "${jobName} - Build ${buildNumber} - ${pipelineStatus.toUpperCase()}",
                body: body,
                to: 'email@gmail.com',
                from: 'jenkins@caddproject.com',
                replyTo: 'jenkins@caddproject.com',
                mimeType: 'text/html'
            )
        }
    }    
}
}


