## Case Study – Future Airlines

# Architecture: 

   Im scaling Jenkins agents on EKS using the Kubernetes plugin for Jenkins, the infrascructure similar as the picture below, im just not doing canary deploymoyments. A good way to watch what is happening behind the scenes in trigger a Jenkins pipeline and watch the pipeline dash and containers being created here (http://kubeops.robeferre.com/). Im executing curl tests, performance tests and security tests.
   
   All terraform code used to provision the cluster is in ./infra folder and the Pipeline specification in on Jenkins file, I coded the pipeline using declarative language.
   
   Helm charts utilized:
      grafana-4.4.0       
      jenkins-1.9.16   	        
      prometheus-10.3.1	    
      sonarqube-3.3.2  	

![alt text](https://cloud.google.com/solutions/images/jenkins-cd-container-engine.svg)

* Pipeline flow utilized:
  https://guides.github.com/introduction/flow/

* Pipeline Dashboard:
  http://jenkins.robeferre.com:8080/blue/organizations/jenkins/example-service/activity
  user: admin
  passwd: admin

* KubeOps view:
  http://kubeops.robeferre.com/

* Grafana:
  http://grafana.robeferre.com/login
  user: admin
  passwd: BPbHcIsaycEqfaZsUcoL9W9mflPyKE6eDcTMjMnt

* Sonar:
  http://sonar.robeferre.com:8080/
  user: admin
  passwd: admin

* App:
  http://app-dev.robeferre.com:8080/
  http://app-stg.robeferre.com:8080/
  http://app-prod.robeferre.com:8080/

* Skipfish:
  https://skipfish.s3.amazonaws.com/output-01-26-2020-13%3A42%3A43/index.html
  This bucket has all penetretion tests that done all pipeline executions. Heres an example of one report.
