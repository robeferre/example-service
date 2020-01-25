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
    image: robeferre/maven-alpine
    command:
    - cat
    tty: true
  - name: kubectl
    image: robeferre/kubectl
    command:
    - cat
    tty: true
  - name: skipfish
    image: robeferre/skipfish
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
        stage('Compile') {
          steps {
            container(name: 'maven') {
              sh 'mvn -f pom.xml compile'
            }

          }
        }

        stage('Unit tests') {
          steps {
            container(name: 'maven') {
              sh 'mvn -f pom.xml test'
            }
          }
        }

        stage('Sonar scan') {
          steps {
            container(name: 'maven') {
              sh 'mvn -f pom.xml compile && mvn sonar:sonar \
                         -Dsonar.projectKey=example-service \
                         -Dsonar.host.url=http://a650a5d463f5311eaa40d0a8f421d27b-448420350.us-east-1.elb.amazonaws.com:8080 \
                         -Dsonar.login=dea0388bc4334e2cb00be05538a081bd05a7293d'
            }
          }
        }
      }
    }

    stage('Publish Docker') {
      when {
        branch 'feature*'
      }
      steps {
        container(name: 'kaniko') {
          sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --insecure --skip-tls-verify \
                                  --cache=true --destination=robeferre/example-service:${GIT_COMMIT}'
        }

      }
    }

    stage('Deploy to Dev') {
      when {
        branch 'feature*'
      }
      steps {
        container(name: 'kubectl') {
          sh 'export PATH=${PATH}:/root/.local/bin && \
              export ENV=dev && \
              aws eks --region us-east-1 update-kubeconfig --name emirates-dev-k8s-cluster && \
              apk add gettext && \
              envsubst < infra/app-deployment.tmpl > infra/app-deployment.yaml && \
              envsubst < infra/app-service.tmpl > infra/app-service.yaml && \
              kubectl apply -f infra/ -n development'
        }
      }
    }

    stage('Dev Tests') {
      parallel {
        stage('Curl http_code') {
          steps {
            container(name: 'kubectl') {
            sh '(curl -L -so /dev/null --fail \"http://a84bb27bc3f8d11eaa40d0a8f421d27b-1231905860.us-east-1.elb.amazonaws.com:8080\";)'
          }}
        }

        stage('Curl size_download') {
          steps {
              container(name: 'kubectl') {
            sh '(curl -L -so /dev/null --fail \"http://a84bb27bc3f8d11eaa40d0a8f421d27b-1231905860.us-east-1.elb.amazonaws.com:8080\" -w \'%{size_download}\';)'
          }}
        }

        stage('Curl total_time') {
          steps {
            container(name: 'kubectl') {
            sh '(cd infra; curl -L -w "@curl-format.txt" -o /dev/null -s \"http://a84bb27bc3f8d11eaa40d0a8f421d27b-1231905860.us-east-1.elb.amazonaws.com:8080\";)'
           }
         }
       }
     }
    }

    stage('Deploy to Staging') {
      when {
        branch 'feature*'
      }
      steps {
        container(name: 'kubectl') {
          sh 'export PATH=${PATH}:/root/.local/bin && \
              export ENV=stg && \
              aws eks --region us-east-1 update-kubeconfig --name emirates-dev-k8s-cluster && \
              apk add gettext && \
              envsubst < infra/app-deployment.tmpl > infra/app-deployment.yaml && \
              envsubst < infra/app-service.tmpl > infra/app-service.yaml && \
              kubectl apply -f infra/ -n staging'
        }
      }
    }

    stage('Staging tests') {
      parallel {
          stage('Integration tests') {
            steps {
              sh 'echo need a test here'
            }
          }

          stage('Load Tests') {
            steps {
              sh 'ls'

            }
          }

          stage('Security Tests') {
            steps {
              container(name: 'skipfish') {
              sh 'skipfish -o output-`date +"%m-%d-%Y-%H:%M:%S"` http://a84bb27bc3f8d11eaa40d0a8f421d27b-1231905860.us-east-1.elb.amazonaws.com:8080/ && \
                  aws s3 cp output/ s3://skipfish/output-`date +"%m-%d-%Y-%H:%M:%S"` --recursive'
              }
            }
          }
       }
    }

    stage('Go for Production?') {
      steps {
        sh 'ls'
      }
    }

    stage('Deploy Production') {
      steps {
        sh 'ls'
      }
    }

    stage('Production tests') {
      parallel {
        stage('Curl http_code') {
          steps {
            sh 'ls'
          }
        }

        stage('Curl size_download') {
          steps {
            sh 'ls'
          }
        }

        stage('Curl total_time') {
          steps {
            sh 'ls'
          }
        }

      }
    }

  }
}
