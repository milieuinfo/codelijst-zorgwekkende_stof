@Library('Cumulus@1.3-stable') _
pipeline {
    agent {
        kubernetes {
            inheritFrom 'jenkins-jenkins-agent'
            yaml podBuilder.from([maven.podSpec(25), dind, sonar, trivy])
        }
    }
    environment {
        SONAR_PROJECT_KEY = 'be.vlaanderen.omgeving.data.id.graph:codelijst-zorgwekkende_stof'
    }
    stages {
        stage("Setup") {
            steps {
                script {
                    if (env.BRANCH_IS_PRIMARY) {
                        properties([versions.releaseParameters()])
                        def currentVersion = maven.version()
                        if (versions.isRelease()) {
                            def version = versions.bump(currentVersion)
                            git.validateTag(version)
                            maven.validateVersion(version)
                            env.VERSION = version
                        }
                    } else {
                        properties([parameters([
                                booleanParam(name: 'DEPLOY', defaultValue: false, description: 'If true, runs mvn deploy instead of mvn verify.')
                        ])])
                    }
                }
            }
        }
        stage("Non-primary branch") {
            when {
                allOf {
                    not { expression { env.BRANCH_IS_PRIMARY } }
                    expression { git.notSkipCi() }
                }
            }
            parallel {
                stage("Trivy scan") {
                    steps {
                        script {
                            trivy.scanFilesystem([targetPath: 'pom.xml'])
                        }
                    }
                }
                stage("Maven verify") {
                    when {
                        expression { !(params.DEPLOY ?: false) }
                    }
                    steps {
                        script {
                            maven.goal([goal: 'verify'])
                        }
                    }
                }
                stage("Maven deploy") {
                    when {
                        expression { params.DEPLOY ?: false }
                    }
                    steps {
                        script {
                            maven.goal([goal: 'deploy'])
                        }
                    }
                }
            }
        }
        stage("Primary branch") {
            when {
                allOf {
                    expression { env.BRANCH_IS_PRIMARY }
                    expression { git.notSkipCi() }
                }
            }
            stages {
                stage("Maven prepare") {
                    when {
                        expression { versions.isRelease() }
                    }
                    steps {
                        script {
                            maven.goal([goal     : 'release:clean release:prepare',
                                        version  : env.VERSION,
                                        skipTests: true
                            ])
                        }
                    }
                }
                stage("Maven deploy") {
                    steps {
                        script {
                            maven.goal([goal: 'deploy'])
                        }
                    }
                }
                stage("Sonar scan") {
                    steps {
                        script {
                            sonar.scanMaven([
                                    projectKey        : env.SONAR_PROJECT_KEY,
                                    tolerateBadQuality: true
                            ])
                        }
                    }
                }
                stage("Maven release") {
                    when {
                        expression { versions.isRelease() }
                    }
                    steps {
                        script {
                            maven.goal([goal     : 'release:perform',
                                        version  : env.VERSION,
                                        skipTests: true
                            ])
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            script {
                pipelineSummary([sonarProjectKey: env.BRANCH_IS_PRIMARY ? env.SONAR_PROJECT_KEY : null])
            }
        }
    }
}
