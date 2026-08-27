pipeline {
    agent any


    environment {
        repo_url = 'https://github.com/surajjagtap221/cravita_project_2.git'
        branch_name = 'main'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: "${branch_name}", url: "${repo_url}"
            }
        }

        stage('Terraform Init') {
            steps {
                dir('blue_green_infra') {
                    sh 'terraform init --reconfigure'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('blue_green_infra') {
                    sh 'terraform plan -lock=false'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('blue_green_infra') {
                    sh 'terraform destroy -auto-approve'
                }
            }
        }
    }
}