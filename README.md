Terraform EKS Cluster with Jenkins Pipeline
This repository contains the necessary configurations and scripts to set up an EKS cluster using Terraform, managed through a Jenkins pipeline. The Jenkinsfile automates the steps required to initialize, plan, and apply the Terraform configurations.

Prerequisites

Before running the Jenkins pipeline, ensure you have the following prerequisites set up:

Terraform: Installed and configured on the Jenkins server.
AWS CLI: Installed and configured with appropriate credentials.
Jenkins: Installed with the necessary plugins:
Pipeline
AWS Credentials
Terraform
Ansible (if needed)
AWS Credentials: Stored in Jenkins using the AWS Credentials plugin.
Terraform Configuration Files: Ensure you have a main.tf, variables.tf, and outputs.tf for your EKS cluster.
Jenkins Pipeline Configuration
The Jenkinsfile defines the pipeline and contains the stages to initialize, plan, and apply the Terraform configurations. Below is the Jenkinsfile used in this project:

Steps to Run the Pipeline
Setup AWS Credentials in Jenkins:

Go to Jenkins Dashboard -> Manage Jenkins -> Manage Credentials.
Add your AWS access key and secret key as a new AWS credential.
Create a Jenkins Job:

Go to Jenkins Dashboard -> New Item.
Enter a name for your job and select "Pipeline".
In the Pipeline section, choose "Pipeline script from SCM" and configure your repository and branch.
Run the Pipeline:

Save the job configuration.
Click on "Build Now" to trigger the pipeline.
Terraform Files
Ensure you have the following Terraform files in your repository
