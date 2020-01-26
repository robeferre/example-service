pipeline {
  agent {
    kubernetes {
      //cloud 'kubernetes'
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
  - name: alpine
    image: robeferre/alpine
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
                         -Dsonar.host.url=http://sonar.robeferre.com:8080 \
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
        container(name: 'alpine') {
          sh 'export PATH=${PATH}:/root/.local/bin && \
              export ENV=dev && \
              aws eks --region us-east-1 update-kubeconfig --name emirates-dev-k8s-cluster && \
              apk add gettext && \
              envsubst < infra/app-deployment.tmpl > infra/app-deployment.yaml && \
              envsubst < infra/app-service.tmpl > infra/app-service.yaml && \
              kubectl apply -f infra/ -n development && \
              kubectl rollout status deployment springboot-backend -n development && \
              sleep 20'
        }
      }
    }

    stage('Dev Tests') {
      when {
        branch 'feature*'
      }
      parallel {
        stage('Curl http_code') {

          steps {
            container(name: 'alpine') {
            sh '(curl -so /dev/null --fail \"http://app-dev.robeferre.com:8080\";)'
          }}
        }

        stage('Curl size_download') {

          steps {
              container(name: 'alpine') {
            sh '(curl -so /dev/null --fail \"http://app-dev.robeferre.com:8080\" -w \'%{size_download}\';)'
          }}
        }

        stage('Curl total_time') {

          steps {
            container(name: 'alpine') {
            sh '(cd infra; curl -w "@curl-format.txt" -o /dev/null -s \"http://app-dev.robeferre.com:8080\";)'
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
        container(name: 'alpine') {
          sh 'export PATH=${PATH}:/root/.local/bin && \
              export ENV=stg && \
              aws eks --region us-east-1 update-kubeconfig --name emirates-dev-k8s-cluster && \
              apk add gettext && \
              envsubst < infra/app-deployment.tmpl > infra/app-deployment.yaml && \
              envsubst < infra/app-service.tmpl > infra/app-service.yaml && \
              kubectl apply -f infra/ -n staging && \
              kubectl rollout status deployment springboot-backend -n staging && \
              sleep 20'
        }
      }
    }

    stage('Staging tests') {
      when {
        branch 'feature*'
      }
      parallel {
          stage('Integration tests') {
            steps {
              sh 'echo need a test here'
            }
          }

          stage('Load Tests') {
            steps {
              container(name: 'alpine') {
              sh 'export PATH=${PATH}:/root/.local/bin && \
                  aws eks --region us-east-1 update-kubeconfig --name emirates-dev-k8s-cluster && \
                  (cd infra; ./start_test.sh jmeter performance_test.jmx;)'
              }
            }
          }

          stage('Security Tests') {
            steps {
              container(name: 'skipfish') {
              sh 'skipfish -o output http://app-stg.robeferre.com:8080 && \
                  aws s3 cp output/ s3://skipfish/output-`date +"%m-%d-%Y-%H:%M:%S"` --recursive'
              }
            }
          }
       }
    }

    stage('Publish Docker:latest') {
      when {
                branch 'master'
      }
      steps {
        container(name: 'kaniko') {
          sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --insecure --skip-tls-verify \
                                  --cache=true --destination=robeferre/example-service:latest'
        }
      }
    }


    stage('Deploy to Production') {
      when {
                branch 'master'
            }
      steps {
        container(name: 'alpine') {
          sh 'export PATH=${PATH}:/root/.local/bin && \
              export ENV=prod && export GIT_COMMIT=latest && \
              aws eks --region us-east-1 update-kubeconfig --name emirates-dev-k8s-cluster && \
              apk add gettext && \
              envsubst < infra/app-deployment.tmpl > infra/app-deployment.yaml && \
              envsubst < infra/app-service.tmpl > infra/app-service.yaml && \
              kubectl apply -f infra/ -n production && \
              kubectl rollout status deployment springboot-backend -n production && \
              sleep 20'
        }
      }
    }

    stage('Production tests') {
      when {
        branch 'master'
      }
      parallel {
        stage('Curl http_code') {

          steps {
            container(name: 'alpine') {
            sh '(curl -so /dev/null --fail \"http://app-prod.robeferre.com:8080\";)'
          }}
        }

        stage('Curl size_download') {

          steps {
              container(name: 'alpine') {
            sh '(curl -so /dev/null --fail \"http://app-prod.robeferre.com:8080\" -w \'%{size_download}\';)'
          }}
        }

        stage('Curl total_time') {

          steps {
            container(name: 'alpine') {
            sh '(cd infra; curl -w "@curl-format.txt" -o /dev/null -s \"http://app-prod.robeferre.com:8080\";)'
           }
         }
       }
     }
    }

  }
}
