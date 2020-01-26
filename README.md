Case Study – Future Airlines

Architecture: 

   Im scaling Jenkins agents on EKS using the Kubernetes plugin for Jenkins, the infrascructure similar as the picture below, im just not doing canary deploymoyments. A nice way to watch what is happening behind the scenes in trigger a Jenkins pipeline and watch the pipeline dash and containers being created here (http://kubeops.robeferre.com/).

![alt text](https://cloud.google.com/solutions/images/jenkins-cd-container-engine.svg)

Pipeline flow utilized:
https://guides.github.com/introduction/flow/

Pipeline Dashboard:
http://jenkins.robeferre.com:8080/blue/organizations/jenkins/example-service/activity
user: admin
passwd: admin

KubeOps view:
http://kubeops.robeferre.com/

Grafana:
http://grafana.robeferre.com/login
user: admin
passwd: BPbHcIsaycEqfaZsUcoL9W9mflPyKE6eDcTMjMnt

Sonar:
http://sonar.robeferre.com:8080/
user: admin
passwd: admin

App:
http://app-dev.robeferre.com:8080/
http://app-stg.robeferre.com:8080/
http://app-prod.robeferre.com:8080/

Skipfish:
https://skipfish.s3.amazonaws.com/output-01-26-2020-13%3A42%3A43/index.html
This bucket has all penetretion tests that has been doneat all pipeline executions. Heres an example of one execution.
