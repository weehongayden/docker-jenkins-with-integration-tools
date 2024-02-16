pipeline {
    agent { label 'Jenkins Agent Alpha' }

    tools {
        maven 'Maven'
        jdk 'JDK'
    }

    environment {
        DOCKER_USERNAME = "weehong"
        PROJECT_NAME = "demo-project"
        BUILD_VERSION = "${env.BUILD_ID}-${env.GIT_COMMIT}"
        IMAGE_NAME = "${PROJECT_NAME}:${BUILD_VERSION}"
    }

    stages {
        stage('Build') {
            steps {
                dir("app") {
                  checkout scm
                }
                sh 'mvn clean package'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    withCredentials([
                        [
                            $class: "VaultTokenCredentialBinding",
                            credentialsId: "vault-token",
                            vaultAddr: "https://vault.weehong.dev"
                        ]
                    ]) {
                        def secrets = [
                            [
                                path: "secret/sonar",
                                engineVersion: 2,
                                secretValues: [
                                    [
                                        envVar: "sonar_project_key", vaultKey: "sonarProjectKey",
                                    ],
                                    [
                                        envVar: "sonar_project_name", vaultKey: "sonarProjectName",
                                    ],
                                    [
                                        envVar: "sonar_url", vaultKey: "sonarUrl",
                                    ],
                                    [
                                        envVar: "sonar_token", vaultKey: "sonarToken",
                                    ]
                                ]
                            ]
                        ]
                        def configuration = [
                            vaultUrl: VAULT_ADDR,
                            vaultCredentialId: "jenkins-approle",
                            engineVersion: 1
                        ]
                        withVault([configuration: configuration, vaultSecrets: secrets]) {
                            withSonarQubeEnv('Sonar') {
                                sh "mvn sonar:sonar \
                                      -Dsonar.projectKey='$env.sonar_project_key' \
                                      -Dsonar.projectName='$env.sonar_project_name' \
                                      -Dsonar.host.url='$env.sonar_url' \
                                      -Dsonar.token='$env.sonar_token'"
                            }
                        }
                    }
                }
            }
        }
        
        stage("Quality Gate") {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage("Build and Push Docker Image") {
          steps {
            script {
              sh """
                docker build -t ${DOCKER_USERNAME}/${PROJECT_NAME} .
                docker tag ${DOCKER_USERNAME}/${PROJECT_NAME} ${DOCKER_USERNAME}/${IMAGE_NAME}
              """

              withCredentials([
                    [
                        $class: "VaultTokenCredentialBinding",
                        credentialsId: "jenkins-approle",
                        vaultAddr: "https://vault.weehong.dev"
                    ]
                ]) {
                    def secrets = [
                        [
                            path: "secret/sonar",
                            engineVersion: 2,
                            secretValues: [
                                [
                                    envVar: "docker_token", vaultKey: "dockerToken",
                                ],
                            ]
                        ]
                    ]
                    def configuration = [
                        vaultUrl: VAULT_ADDR,
                        vaultCredentialId: "jenkins-approle",
                        engineVersion: 1
                    ]
                    withVault([configuration: configuration, vaultSecrets: secrets]) {
                        withSonarQubeEnv('Sonar') {
                            sh """
                                echo $env.docker_token | docker login --username ${DOCKER_USERNAME} --password-stdin
                                docker push ${DOCKER_USERNAME}/${PROJECT_NAME}
                            """
                        }
                    }
                }
            }
          }
        }
    }
}
