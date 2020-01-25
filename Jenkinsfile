pipeline {
  agent {
    kubernetes {
      defaultContainer 'kaniko'
      yaml '''
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug-a2aae6274dd5805bb9ca60c392a7f2d0a33c4045
    imagePullPolicy: Always
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
      - name: jenkins-docker-cfg
        mountPath: /kaniko/.docker
  - name: maven
    image: maven:alpine
    command:
    - cat
    tty: true
  - name: kubectl
    image: robeferre/kubectl
    command:
    - cat
    tty: true
  volumes:
  - name: jenkins-docker-cfg
    projected:
      sources:
      - secret:
          name: regcred
          items:
            - key: .dockerconfigjson
              path: config.json
'''
    }

  }
  stages {
    stage('Build') {
      when {
                branch 'feature*'
            }
      parallel {
        stage('Validate') {
          steps {
             container('maven') {
               sh 'mvn -f pom.xml compile'
             }
          }
        }
        stage('Unit tests') {
          steps {
            container('maven') {
              sh 'mvn -f pom.xml test'
            }
          }
        }
        stage('Sonar scan') {
          steps {
            container('maven') {
              sh 'mvn -f pom.xml compile && mvn sonar:sonar \
                    -Dsonar.projectKey=example-service \
                    -Dsonar.host.url=http://a650a5d463f5311eaa40d0a8f421d27b-448420350.us-east-1.elb.amazonaws.com:8080 \
                    -Dsonar.login=dea0388bc4334e2cb00be05538a081bd05a7293d'
             }
           }
         }
      }
    }

    stage('Push to registry') {
      when {
                branch 'feature*'
            }
      steps {
         container('kaniko') {
           sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --insecure --skip-tls-verify \
                  --cache=true --destination=robeferre/example-service:${GIT_COMMIT}'
         }
      }
    }

    stage('Deploy Dev') {
      when {
                branch 'feature*'
            }
      steps {
        container('kubectl') {
          sh 'export PATH=${PATH}:/root/.local/bin && \
              export ENV=dev && \
              aws eks --region us-east-1 update-kubeconfig --name emirates-dev-k8s-cluster && \
              envsubst < app-deployment.tmpl > app-deployment.yaml && \
              envsubst < app-service.tmpl > app-service.yaml &&
              kubectl apply -f infra/ -n development'
        }
      }
    }

    stage('Tests') {
      parallel {
        stage('Load test') {
          steps {
            sh 'ls'
          }
        }

        stage('Security test') {
          steps {
            sh 'ls'
          }
        }

        stage('Integration test') {
          steps {
            sh 'ls'
          }
        }

      }
    }

    stage('Open PR') {
      steps {
        sh 'ls'
      }
    }

    stage('Deploy Prod') {
      steps {
        sh 'ls'
      }
    }

  }
}
