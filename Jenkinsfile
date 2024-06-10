pipeline {
    agent any

    environment {
        // Specify your AWS credentials here
        AWS_ACCESS_KEY_ID = credentials('simon-aws-creds')
        AWS_SECRET_ACCESS_KEY = credentials('simon-aws-creds')
        AWS_REGION = 'us-west-2' // Change to your desired AWS region
    }

    stages {
        stage('Clone Repository') {
            steps {
                // Clone the repository containing your Terraform configuration
                git url: 'https://github.com/simonkolz/EKS.git', branch: 'main'
            }
        }

        stage('Initialize Terraform') {
            steps {
                // Initialize Terraform
                sh 'terraform init'
            }
        }

        stage('Plan Terraform') {
            steps {
                // Run Terraform plan
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Apply Terraform') {
            steps {
                // Apply the Terraform plan to create the EKS cluster
                sh 'terraform apply -input=false tfplan'
            }
        }
    }

    post {
        always {
            // Clean up workspace after build
            cleanWs()
        }
    }
}
