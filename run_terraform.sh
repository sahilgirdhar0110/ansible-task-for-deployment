#!/usr/bin/env bash

###################################################################
#Script Name	: run_terraform.sh
#Description	: This script to manage terraform actions
#Args         :
#Author       : Muhammad Asif,Navjot Singh
#Email        : navjot.singh@oaknorth.com, muhammad.asif@oaknorth.com
###################################################################


##This file is used to run terraform

source ${PROJECT_ROOT}/script/logging.sh

copy_tfvars_from_S3(){
log_info "Downloading terraform.tfvars file from S3 bucket"
  aws s3api get-object --bucket "${TF_VAR_owner}-${TF_VAR_environment}-terraform-tfvars" terraform.tfvars --key "terraform.tfvars"
  mv terraform.tfvars ${PROJECT_ROOT}/config/aws/
  log_info_1 "Terraform variable file copied to aws directory"
}

copy_secrets_tfvars_from_S3(){
log_info "Downloading secrets.tfvars file from S3 bucket"
  aws s3api get-object --bucket "${TF_VAR_owner}-${TF_VAR_environment}-secrets-store" secrets.tfvars --key "secrets.tfvars"
  mv secrets.tfvars ${PROJECT_ROOT}/config/aws/
  log_info_1 "Secrets variable file copied to aws directory"
}
copy_mulesoft_file_from_S3(){
log_info "Downloading terraform.tfvars file from S3 bucket"
  aws s3api get-object --bucket "${TF_VAR_owner}-${TF_VAR_environment}-mulesoft-configuration" muleconfiguration --key "muleconfiguration"
  mv muleconfiguration ${PROJECT_ROOT}/ansible/group_vars/
  log_info_1 "Terraform variable file copied to aws directory"
}
copy_ansible_vars_from_S3(){
  log_info "Downloading ansible vars file from S3 bucket"
  aws s3api get-object --bucket "${TF_VAR_owner}-${TF_VAR_environment}-ansible-group-vars" ${TF_VAR_environment}_ansible_var --key "${TF_VAR_environment}_ansible_var"
  aws s3api get-object --bucket "${TF_VAR_owner}-${TF_VAR_environment}-ansible-group-vars" ${TF_VAR_environment}_secrets --key "${TF_VAR_environment}_secrets"
  mv ${TF_VAR_environment}_ansible_var ${PROJECT_ROOT}/ansible/group_vars/
  mv ${TF_VAR_environment}_secrets ${PROJECT_ROOT}/ansible/group_vars/
  log_info_1 "Ansible variable file copied to group_vars directory"
}

copy_ansible_secret_from_S3(){
  log_info "Downloading ansible secret vars file from S3 bucket"
  aws s3api get-object --bucket "${TF_VAR_owner}-${TF_VAR_environment}-ansible-group-vars" ${TF_VAR_environment}_secrets --key "${TF_VAR_environment}_secrets"
  mv ${TF_VAR_environment}_secrets ${PROJECT_ROOT}/ansible/group_vars/
  log_info_1 "Ansible variable file copied to group_vars directory"
}

copy_tfvars_from_azure_blob(){
  log_info "Downloading terraform.tfvars file from the store"
  access_key=`az storage account keys list \
      --resource-group ${TF_VAR_owner}-${TF_VAR_environment} \
      --account-name ${TF_VAR_owner}${TF_VAR_environment}vars \
      --query [0].value | sed -e 's/"//g'`
  azcopy --source https://${TF_VAR_owner}${TF_VAR_environment}vars.blob.core.windows.net/terraform-vars/terraform.tfvars --destination terraform.tfvars --source-key $access_key
  mv terraform.tfvars ${PROJECT_ROOT}/config/azure/
  log_info_1 "Terraform variable file copied to azure directory"
}

copy_azure_secrets_tfvars_from_azure_blob(){
  log_info "Downloading secrets.tfvars file from the store"
  access_key=`az storage account keys list \
      --resource-group ${TF_VAR_owner}-${TF_VAR_environment} \
      --account-name ${TF_VAR_owner}${TF_VAR_environment}secrets \
      --query [0].value | sed -e 's/"//g'`
  azcopy --source https://${TF_VAR_owner}${TF_VAR_environment}secrets.blob.core.windows.net/terraform-secrets/secrets.tfvars --destination secrets.tfvars --source-key $access_key
  azcopy --source https://${TF_VAR_owner}${TF_VAR_environment}secrets.blob.core.windows.net/terraform-secrets/id_rsa.pub --destination id_rsa.pub --source-key $access_key
  mv secrets.tfvars ${PROJECT_ROOT}/config/azure/
  mv id_rsa.pub ${PROJECT_ROOT}/config/azure/
  log_info_1 "Terraform secrets config variable file copied to azure directory"
}

copy_ansible_vars_from_azure_blob(){
  log_info "Downloading ansible vars file from the store"
  access_key=`az storage account keys list \
      --resource-group ${TF_VAR_owner}-${TF_VAR_environment} \
      --account-name ${TF_VAR_owner}${TF_VAR_environment}vars \
      --query [0].value | sed -e 's/"//g'`
  azcopy --source https://${TF_VAR_owner}${TF_VAR_environment}vars.blob.core.windows.net/ansible-vars/${TF_VAR_environment}_ansible_var --destination ${TF_VAR_environment}_ansible_var --source-key $access_key
  mv ${TF_VAR_environment}_ansible_var ${PROJECT_ROOT}/ansible/group_vars/
  log_info_1 "Ansible variable file copied to group_vars directory"
}

copy_ansible_secret_vars_from_azure_blob(){
  log_info "Downloading ansible secret vars file from the store"
  access_key=`az storage account keys list \
      --resource-group ${TF_VAR_owner}-${TF_VAR_environment} \
      --account-name ${TF_VAR_owner}${TF_VAR_environment}secrets \
      --query [0].value | sed -e 's/"//g'`
  azcopy --source https://${TF_VAR_owner}${TF_VAR_environment}secrets.blob.core.windows.net/ansible-secrets/${TF_VAR_environment}_secrets --destination ${TF_VAR_environment}_secrets --source-key $access_key
  mv ${TF_VAR_environment}_secrets ${PROJECT_ROOT}/ansible/group_vars/
  log_info_1 "Ansible variable file copied to group_vars directory"
}

copy_batch_war_from_azure_blob(){
  log_info "Downloading batch war file from the store"
  access_key=`az storage account keys list \
      --resource-group ${TF_VAR_owner}-${TF_VAR_environment} \
      --account-name ${TF_VAR_owner}${TF_VAR_environment}vars \
      --query [0].value | sed -e 's/"//g'`
  azcopy --source https://${TF_VAR_owner}${TF_VAR_environment}vars.blob.core.windows.net/batch-war/mamboo-batch-2.9.0.war --destination mamboo-batch-2.9.0.war --source-key $access_key
  azcopy --source https://${TF_VAR_owner}${TF_VAR_environment}vars.blob.core.windows.net/batch-war/hawtio.war --destination hawtio.war --source-key $access_key
  mv mamboo-batch-2.9.0.war ${PROJECT_ROOT}/config/azure/
  mv hawtio.war ${PROJECT_ROOT}/config/azure/
  log_info_1 "Terraform variable file copied to azure directory"
}

if [[ "$platform" == "aws" ]]; then
    if [[ "$run_command" == "--init" ]]; then
      log_info_1 "Creating prerequisite for environment $TF_VAR_environment"
      log_info_1 "Creating S3 buckets for environment $TF_VAR_environment"
      source ${PROJECT_ROOT}/script/aws_s3.sh
      log_info_1 "S3 buckets completed for environment $TF_VAR_environment"
      log_info_1 "Prerequisite completed $TF_VAR_environment"
      exit
    elif [[ "$run_command" == "--plan" ]]; then
      log_info "Initiated script for S3 bucket"
      copy_tfvars_from_S3
      copy_secrets_tfvars_from_S3
      cd ${PROJECT_ROOT}/${CONFIG_DIR}/${platform}
      log_info "Initializing terraform modules $TF_VAR_environment"
      terraform init -backend-config="bucket=${TF_VAR_owner}-${TF_VAR_environment}-terraform-state" -backend-config="key=terraform.tfstate" -backend-config="region=${TF_VAR_aws_region}" -reconfigure -backend=true -force-copy -get=true -input=false
      log_info_1 "Initializing terraform plan for environment  $TF_VAR_environment"
      terraform plan -var-file="secrets.tfvars" -var region=${TF_VAR_aws_region}
      log_info_1 "Terraform plan completed for environment $TF_VAR_environment"
      exit
    elif [[ "$run_command" == "--apply" ]]; then
      log_info_1 "Initializing terraform apply forenvironment $TF_VAR_environment"
      log_info_1 "Started creating Infrastructure at `date +"%T"` BST"
      copy_tfvars_from_S3
      copy_secrets_tfvars_from_S3
      cd ${PROJECT_ROOT}/${CONFIG_DIR}/${platform}
      terraform init -backend-config="bucket=${TF_VAR_owner}-${TF_VAR_environment}-terraform-state" -backend-config="key=terraform.tfstate" -backend-config="region=${TF_VAR_aws_region}" -reconfigure -backend=true -force-copy -get=true -input=false
      terraform apply -var-file="secrets.tfvars" -var region=${TF_VAR_aws_region}
      log_info_1 "Terraform apply completed for environment $TF_VAR_environment"
      log_info_1 "Infrastructure created at `date +"%T"` BST"
      exit
    elif [[ "$run_command" == "--destroy" ]]; then
      log_info "Initializing terraform deploy for environment $TF_VAR_environment"
      copy_tfvars_from_S3
      copy_secrets_tfvars_from_S3
      cd ${PROJECT_ROOT}/${CONFIG_DIR}/${platform}
      export TF_WARN_OUTPUT_ERRORS=1
      terraform init -backend-config="bucket=${TF_VAR_owner}-${TF_VAR_environment}-terraform-state" -backend-config="key=terraform.tfstate" -backend-config="region=${TF_VAR_aws_region}" -reconfigure -backend=true -force-copy -get=true -input=false
      terraform destroy -force -var-file="secrets.tfvars" -var region=${TF_VAR_aws_region}
      rm -rf /opt/integrationhub /opt/quartz /opt/transactionportal
      log_info_1 "Terraform destroy completed for environment $TF_VAR_environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} == "tpwebprelive" ]]; then
      log_info_1 "Initializing ansible prerequisite for $TF_VAR_environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/transactional-portal-web-prelive1.yml  --extra-vars "owner=$TF_VAR_owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info "Prerequisite completed on environment" $environment
      exit
    # elif [[ "$run_command" == "--ansible" && ${application} == "tpjobsprelive" ]]; then
    #   log_info_1 "Initializing ansible prerequisite for $TF_VAR_environment"
    #   copy_ansible_vars_from_S3
    #   cd ${PROJECT_ROOT}/ansible/
    #   chmod +x ec2.py
    #   ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/transactional-portal-jobs-prelive1.yml  --extra-vars "owner=$TF_VAR_owner platform=$platform env=$environment region=$TF_VAR_aws_region"
    #   log_info "Prerequisite completed on environment" $environment
    #   exit
    elif [[ "$run_command" == "--ansible" && ${application} = "tpjobsprelive" ]]; then
      log_info "Start Deploying tpjobsprelive on environment $environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/transactional-portal-jobs-prelive1.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      if [ $? -eq 0 ]; then
          log_info_1 "Deployment completed for tpjobsprelive on environment $environment"
          exit
      else
          log_info_1 "Deployment could not completed for tpjobsprelive service on environment $environment.Please look into logs"
          exit 1
      fi
    elif [[ "$run_command" == "--ansible" && ${application} == "backendprelive" ]]; then
      log_info_1 "Initializing ansible prerequisite for $TF_VAR_environment"
      #copy_ansible_vars_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/backend-prelive.yml  --extra-vars "owner=$TF_VAR_owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info "Prerequisite completed on environment" $environment
      exit
    elif [[ "$run_command" == "--ansible" && ${application} == "bacs" ]]; then
      log_info_1 "Initializing ansible prerequisite for $TF_VAR_environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/bacs-prelive.yml  --extra-vars "owner=$TF_VAR_owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      #ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/elasticsearch.yml  --extra-vars "owner=$TF_VAR_owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      #ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/graylog.yml  --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      # ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/database-schema.yml  --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      if [ $? -eq 0 ]; then
          log_info_1 "Deployment completed for bacs on environment $environment"
          exit
      else
          log_info_1 "Deployment could not completed for bacs service on environment $environment. Please check into cloudwatch logs"
          exit 1
      fi
    elif [[ "$run_command" == "--ansible" && ${application} == "tpjobsprelive12" ]]; then
      log_info_1 "Initializing ansible prerequisite for $TF_VAR_environment"
      copy_ansible_vars_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/transactional-portal-jobs-prelive1.yml  --extra-vars "owner=$TF_VAR_owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      #ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/elasticsearch.yml  --extra-vars "owner=$TF_VAR_owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      #ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/graylog.yml  --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      # ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/database-schema.yml  --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info "Prerequisite completed on environment" $environment
      exit
    elif [[ "$run_command" == "--ansible" && ${application} == "keycloak" ]]; then
      log_info "Start Deploying Keycloak for $environment"
      copy_ansible_vars_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      # ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/fqdn.yml  --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/keycloak.yml  --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for Keycloak on environment $environment"
      exit
    # elif [[ "$run_command" == "--ansible" && ${application} == "tpjobs2" ]]; then
    # log_info "Start Deploying Keycloak for $environment"
    # copy_ansible_vars_from_S3
    # cd ${PROJECT_ROOT}/ansible/
    # chmod +x ec2.py
    # # ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/fqdn.yml  --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
    # ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/transactional-portal-jobs-prelive1.yml  --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
    # log_info_1 "Deployment completed for Keycloak on environment $environment"
    # exit
    elif [[ "$run_command" == "--ansible" && ${application} == "journey" ]]; then
      log_info "Start Deploying Journey on environment $environment"
      copy_ansible_vars_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      #ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/rest-service.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/retaildeposits-service.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      #  ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/backend.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      # ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/automated-api.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      # ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/entity-evalution.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for Journey on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} == "frontend" ]]; then
      log_info "Start Deploying Journey on environment $environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/retaildeposits-service.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for Journey on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} == "frontendprelive" ]]; then
      log_info "Start Deploying Journey on environment $environment"
      copy_ansible_vars_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/retaildeposits-service1.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for Journey on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} == "backend" ]]; then
      log_info "Start Deploying Journey on environment $environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/backend.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      if [ $? -eq 0 ]; then
          log_info_1 "Deployment completed for Backned Journey on environment $environment and docker service is in steady state"
          exit
      else
          log_info_1 "Deployment could not completed for Journey on environment $environment"
          exit 1
      fi
      
    elif [[ "$run_command" == "--ansible" && ${application} == "muledeploy" ]]; then
      log_info "Start Deploying Mulesoft on environment $environment"
     # copy_mulesoft_file_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      ansible-playbook -i ec2.py --private-key=/var/lib/jenkins/${owner}${environment}.pem playbooks/muleesb-deploy-${environment}.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment Mulesoft for Journey on environment $environment"
      exit  
    elif [[ "$run_command" == "--ansible" && ${application} == "batch" ]]; then
      log_info "Start Deploying Journey on environment $environment"
      #copy_ansible_vars_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/batch-service.yml  --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for Journey on environment $environment"
      exit
      # elif [[ "$run_command" == "--ansible" && ${application} == "tpjobs2" ]]; then
      # log_info "Start Deploying Journey on environment $environment"
      # copy_ansible_vars_from_S3
      # cd ${PROJECT_ROOT}/ansible/
      # chmod +x ec2.py
      # ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/transactional-portal-jobs-prelive1.yml  --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      # log_info_1 "Deployment completed for Journey on environment $environment"
      # exit
    elif [[ "$run_command" == "--ansible" && ${application} = "tportalweb" ]]; then
      log_info "Start Deploying tportal on environment $environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
       ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/transactional-portal-web.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for tportal on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} = "tportalapi" ]]; then
      log_info "Start Deploying tportal on environment $environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/transactional-portal-api.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      if [ $? -eq 0 ]; then
          log_info_1 "Deployment completed for tportalapi on environment $environment"
          exit
      else
          log_info_1 "Deployment could not completed for tportalapi service on environment $environment.Please look into logs"
          exit 1
      fi
      
      # elif [[ "$run_command" == "--ansible" && ${application} = "tpapi2" ]]; then
      # log_info "Start Deploying tportal on environment $environment"
      # copy_ansible_vars_from_S3
      # cd ${PROJECT_ROOT}/ansible/
      # chmod +x ec2.py
      #  ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/transactional-portal-api-prelive1.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      # log_info_1 "Deployment completed for tportal on environment $environment"
      # exit
    elif [[ "$run_command" == "--ansible" && ${application} = "tportaljobs" ]]; then
      log_info "Start Deploying tportal on environment $environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
       ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/transactional-portal-jobs.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for tportal on environment $environment"
      exit
    # elif [[ "$run_command" == "--ansible" && ${application} = "backendprelive1" ]]; then
    #   log_info "Start Deploying tportal on environment $environment"
    #   copy_ansible_vars_from_S3
    #   cd ${PROJECT_ROOT}/ansible/
    #   chmod +x ec2.py
    #    ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/backend-prelive1.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
    #   log_info_1 "Deployment completed for tportal on environment $environment"
    #   exit
    elif [[ "$run_command" == "--ansible" && ${application} = "tportalbackoffice" ]]; then
      log_info "Start Deploying tportal on environment $environment"
      #copy_ansible_vars_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
       ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/transactional-portal-backoffice.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for tportal on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} = "imcalcapi" ]]; then
      log_info "Start Deploying tportal on environment $environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
       ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/imcalc-api.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for tportal on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} = "imcalcjobs" ]]; then
      log_info "Start Deploying tportal on environment $environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
       ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/imcalc-jobs.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for tportal on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} = "paymentoutweb" ]]; then
      log_info "Start Deploying tportal on environment $environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
       ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/payments-out-web.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for tportal on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} = "paymentoutapi" ]]; then
      log_info "Start Deploying tportal on environment $environment"
      copy_ansible_vars_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
       ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/payments-out-api.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for tportal on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} = "tpnew" ]]; then
      log_info "Start Deploying tportal on environment $environment"
      #copy_ansible_vars_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
       ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/transactional-portal-api-prelive1.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for tportal on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} = "productconfig" ]]; then
      log_info "Start Deploying productconfig on environment $environment"
      #copy_ansible_vars_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
       ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/productconfigprelive.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for productconfig on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} = "loanoriginator" ]]; then
      log_info "Start Deploying loanoriginator on environment $environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
       ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/loanoriginator.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for loanoriginator on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} = "nucleusloanprocessor" ]]; then
      log_info "Start Deploying nucleusloanprocessor on environment $environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
       ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/nucleusloanprocessor.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for nucleusloanprocessor on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} = "lendingmigration" ]]; then
      log_info "Start Deploying lendingmigration on environment $environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
       ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/lendingmigration.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for lendingmigration on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} = "complyadvantage" ]]; then
      log_info "Start Deploying complyadvantage on environment $environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/complyadvantage.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      if [ $? -eq 0 ]; then
          log_info_1 "Deployment completed for complyadvantage application on environment $environment"
          exit
      else
          log_info_1 "Deployment could not completed for complyadvantage service on environment $environment. Please check into cloudwatch logs"
          exit 1
      fi
      
    elif [[ "$run_command" == "--ansible" && ${application} = "transactionmonitoring" ]]; then
      log_info "Start Deploying transactionmonitoring on environment $environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/transactionmonitoring.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      if [ $? -eq 0 ]; then
          log_info_1 "Deployment completed for transactionmonitoring on environment $environment"
          exit
      else
          log_info_1 "Deployment could not completed for transactionmonitoring service on environment $environment.Please look into logs"
          exit 1
      fi
      
    elif [[ "$run_command" == "--ansible" && ${application} = "oaknorthmonitoring" ]]; then
      log_info "Start Deploying oaknorthmonitoring on environment $environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/oaknorthmonitoring.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      if [ $? -eq 0 ]; then
          log_info_1 "Deployment completed for oaknorthmonitoring on environment $environment"
          exit
      else
          log_info_1 "Deployment could not completed for oaknorthmonitoring service on environment $environment.Please look into logs"
          exit 1
      fi

    elif [[ "$run_command" == "--ansible" && ${application} = "oaknorthconfigmanagement" ]]; then
      log_info "Start Deploying oaknorthconfigmanagement on environment $environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/oaknorthconfigmanagement.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      if [ $? -eq 0 ]; then
          log_info_1 "Deployment completed for oaknorthconfigmanagement on environment $environment"
          exit
      else
          log_info_1 "Deployment could not completed for oaknorthconfigmanagement service on environment $environment.Please look into logs"
          exit 1
      fi
      
    elif [[ "$run_command" == "--ansible" && ${application} = "integrationhub" ]]; then
      log_info "Start Deploying integrationhub on environment $environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/integrationhub.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      if [ $? -eq 0 ]; then
          log_info_1 "Deployment completed for integrationhub on environment $environment"
          exit
      else
          log_info_1 "Deployment could not completed for integrationhub service on environment $environment.Please look into cloudwatch logs"
          exit 1
      fi
      
    elif [[ "$run_command" == "--ansible" && ${application} = "audit" ]]; then
      log_info "Start Deploying audit on environment $environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
       ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/audit.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for audit on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} = "oaknorthanalytics" ]]; then
      log_info "Start Deploying analytics on environment $environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/oaknorth-analytics.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      if [ $? -eq 0 ]; then
          log_info_1 "Deployment completed for oaknorthanalytics on environment $environment"
          exit
      else
          log_info_1 "Deployment could not completed for oaknorthanalytics service on environment $environment.Please look into cloudwatch logs"
          exit 1
      fi
      
    elif [[ "$run_command" == "--ansible" && ${application} = "notification" ]]; then
      log_info "Start Deploying notification on environment $environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/notification.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      if [ $? -eq 0 ]; then
          log_info_1 "Deployment completed for notification on environment $environment"
          exit
      else
          log_info_1 "Deployment could not completed for notification service on environment $environment.Please look into logs"
          exit 1
      fi
      
    elif [[ "$run_command" == "--ansible" && ${application} = "loanprocessor" ]]; then
      log_info "Start Deploying loanprocessor on environment $environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
       ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/loanprocessor.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for loanprocessor on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} = "cacheutil" ]]; then
      log_info "Start Deploying cache-util on environment $environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/cache-util.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      if [ $? -eq 0 ]; then
          log_info_1 "Deployment completed for cacheutil application on environment $environment"
          exit
      else
          log_info_1 "Deployment could not completed for cacheutil application on environment $environment. Please check into cloudwatch logs"
          exit 1
      fi
    elif [[ "$run_command" == "--ansible" && ${application} = "accountservice" ]]; then
      log_info "Start Deploying accountservice on environment $environment"
      #copy_ansible_vars_from_S3
      copy_ansible_secret_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
       ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/accountservice.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for accountservice on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} = "paymentin" ]]; then
    log_info "Start Deploying paymentin on environment $environment"
    copy_ansible_secret_from_S3
    #copy_ansible_vars_from_S3
    cd ${PROJECT_ROOT}/ansible/
    chmod +x ec2.py
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/paymentin.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
    log_info_1 "Deployment completed for paymentin on environment $environment"
    exit
    elif [[ "$run_command" == "--ansible" && ${application} = "cloakwork" ]]; then
      log_info "Start Deploying tportal on environment $environment"
      copy_ansible_vars_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
       ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/clockwork-sms-api.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for tportal on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} = "tportal" ]]; then
      log_info "Start Deploying tportal on environment $environment"
      copy_ansible_vars_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      #  ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/transactional-portal-api.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      # ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/transactional-portal-backoffice.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
        # ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/transactional-portal-web.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      # ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/clockwork-sms-api.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      # ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/experian-client.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
       ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/transactional-portal-jobs.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      #  ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/imcalc-api.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      # ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/imcalc-jobs.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      #  ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/payments-out-web.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      #  ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/payments-out-jobs.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for tportal on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} = "finance-automation" ]]; then
      log_info "Start Deploying Finance Automation on environment $environment"
      copy_ansible_vars_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/finance-automation.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for Finance Automation on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} = "paymentsout" ]]; then
      log_info "Start Deploying Payments Out on environment $environment"
      #copy_ansible_vars_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      # ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/payments-out-web.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/payments-out-jobs.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for Payments Out on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} = "activemq" ]]; then
      log_info "Start Deploying Queuing System on environment $environment"
      copy_ansible_vars_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/activemq-service.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/activemq-service.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for Queuing System on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} = "website" ]]; then
      log_info "Start Deploying website on environment $environment"
      copy_ansible_vars_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/website.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_aws_region"
      log_info_1 "Deployment completed for website on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} == "waf" ]]; then
      log_info_1 "Creating WAF for $TF_VAR_environment in Azure"
      copy_ansible_vars_from_S3
      cd ${PROJECT_ROOT}/ansible/
      chmod +x ec2.py
      ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/azure-application-gateway.yml  --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region status=create"
      log_info "WAF created in environment" $environment
      exit
    else
      echo "Please pass appropriate parameter to run this script"
      usage
      exit
    fi
elif [[ "$platform" == "azure" ]]; then
    if [[ "$run_command" == "--init" ]]; then
      log_info "Initializing environment $TF_VAR_environment"
      ${PROJECT_ROOT}/script/azure/azure_resource_group.sh --owner $owner --environment $environment --location $azure_region
      ${PROJECT_ROOT}/script/azure/azure_blob.sh --storage_account_name ${owner}${environment}terraform --container_name terraform-state-file --location $azure_region --resource_group "${owner}-${environment}" --sku Standard_LRS
      ${PROJECT_ROOT}/script/azure/azure_blob.sh --storage_account_name ${owner}${environment}vars --container_name terraform-vars --location $azure_region --resource_group "${owner}-${environment}" --sku Standard_LRS
      ${PROJECT_ROOT}/script/azure/azure_blob.sh --storage_account_name ${owner}${environment}vars --container_name ansible-vars --location $azure_region --resource_group "${owner}-${environment}" --sku Standard_LRS
      ${PROJECT_ROOT}/script/azure/azure_blob.sh --storage_account_name ${owner}${environment}secrets --container_name ansible-secrets --location $azure_region --resource_group "${owner}-${environment}" --sku Standard_LRS
      ${PROJECT_ROOT}/script/azure/azure_blob.sh --storage_account_name ${owner}${environment}secrets --container_name terraform-secrets --location $azure_region --resource_group "${owner}-${environment}" --sku Standard_LRS
      log_info "Initialization successfully completed"
      exit
    elif [[ "$run_command" == "--plan" ]]; then
      echo -e "\n---------------"
      echo "Starting dry run"
      echo -e "---------------\n"
      copy_tfvars_from_azure_blob
      copy_azure_secrets_tfvars_from_azure_blob
      cd ${PROJECT_ROOT}/${CONFIG_DIR}/${platform}
      log_info "Initializing terraform modules $TF_VAR_environment"
      ACCESS_KEY=`az storage account keys list \
          --resource-group ${TF_VAR_owner}-${TF_VAR_environment} \
          --account-name ${TF_VAR_owner}${TF_VAR_environment}terraform \
          --query [0].value | sed -e 's/"//g'`
      terraform init -backend-config="storage_account_name=${TF_VAR_owner}${TF_VAR_environment}terraform" -backend-config="container_name=terraform-state" -backend-config="key=terraform.tfstate" -backend-config="access_key=$ACCESS_KEY" -reconfigure -backend=true -force-copy -get=true -input=false
      log_info_1 "Initializing terraform plan for environment  $TF_VAR_environment"
      terraform plan -var-file="secrets.tfvars"
      log_info "Terraform plan completed for environment $TF_VAR_environment"
      exit
    elif [[ "$run_command" == "--apply" ]]; then
      echo -e "\n-------------------------------------------------"
      echo "Creating $TF_VAR_environment environment in Azure"
      echo -e "-------------------------------------------------\n"
      copy_tfvars_from_azure_blob
      copy_azure_secrets_tfvars_from_azure_blob
      cd ${PROJECT_ROOT}/${CONFIG_DIR}/${platform}
      ACCESS_KEY=`az storage account keys list \
          --resource-group ${TF_VAR_owner}-${TF_VAR_environment} \
          --account-name ${TF_VAR_owner}${TF_VAR_environment}terraform \
          --query [0].value | sed -e 's/"//g'`
      terraform init -backend-config="storage_account_name=${TF_VAR_owner}${TF_VAR_environment}terraform" -backend-config="container_name=terraform-state" -backend-config="key=terraform.tfstate" -backend-config="access_key=$ACCESS_KEY" -reconfigure -backend=true -force-copy -get=true -input=false
      terraform apply -var-file="secrets.tfvars"
      log_info "$TF_VAR_environment environment completed successfully in Azure"
      exit
    elif [[ "$run_command" == "--destroy" ]]; then
      log_info "Destroying $TF_VAR_environment environment in Azure"
      copy_tfvars_from_azure_blob
      copy_azure_secrets_tfvars_from_azure_blob
      cd ${PROJECT_ROOT}/${CONFIG_DIR}/${platform}
      export TF_WARN_OUTPUT_ERRORS=1
      ACCESS_KEY=`az storage account keys list \
          --resource-group ${TF_VAR_owner}-${TF_VAR_environment} \
          --account-name ${TF_VAR_owner}${TF_VAR_environment}terraform \
          --query [0].value | sed -e 's/"//g'`
      ansible-playbook ${PROJECT_ROOT}/ansible/playbooks/azure-application-gateway.yml  --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region status=destroy"
      terraform init -backend-config="storage_account_name=${TF_VAR_owner}${TF_VAR_environment}terraform" -backend-config="container_name=terraform-state" -backend-config="key=terraform.tfstate" -
      -config="access_key=$ACCESS_KEY" -reconfigure -backend=true -force-copy -get=true -input=false
      terraform destroy -force -var-file="secrets.tfvars"
      rm -rf /opt/integrationhub /opt/quartz /opt/transactionportal
      log_info_1 "$TF_VAR_environment environment destroyed from Azure"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} == "prerequisite" ]]; then
      log_info_1 "Initializing ansible prerequisite for $TF_VAR_environment"
      copy_ansible_vars_from_azure_blob
      copy_ansible_secret_vars_from_azure_blob
      cd ${PROJECT_ROOT}/ansible/
      chmod +x azure_rm.py
       ansible-playbook -i ec2.py --private-key=/root/${owner}${environment}.pem playbooks/fqdn.yml  --extra-vars "owner=$TF_VAR_owner platform=$platform env=$environment region=$TF_VAR_region"
       ansible-playbook -i hosts playbooks/elasticsearch.yml  --extra-vars "owner=$TF_VAR_owner platform=$platform env=$environment region=$TF_VAR_azure_region"
       ansible-playbook playbooks/database-schema.yml  --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region"
       ansible-playbook playbooks/azuremount.yml -i hosts --private-key=/root/.ssh/azure_key/id_rsa --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region"
       log_info "Prerequisite completed on environment" $environment
      exit
    elif [[ "$run_command" == "--ansible" && ${application} == "keycloak" ]]; then
      log_info "Start Deploying Keycloak for $environment"
      copy_ansible_vars_from_azure_blob
      copy_ansible_secret_vars_from_azure_blob
      cd ${PROJECT_ROOT}/ansible/
      chmod +x azure_rm.py
      ansible-playbook playbooks/fqdn.yml  --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region"
      ansible-playbook playbooks/keycloak.yml  --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region"
      log_info_1 "Deployment completed for Keycloak on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} == "journey" ]]; then
      log_info "Start Deploying Journey on environment $environment"
      copy_ansible_vars_from_azure_blob
      copy_ansible_secret_vars_from_azure_blob
      copy_batch_war_from_azure_blob
      cd ${PROJECT_ROOT}/ansible/
      chmod +x azure_rm.py
      # ansible-playbook playbooks/retaildeposits-service.yml  --extra-vars "owner=$TF_VAR_owner platform=$platform env=$environment region=$TF_VAR_azure_region"
      # ansible-playbook playbooks/backend.yml  --extra-vars "owner=$TF_VAR_owner platform=$platform env=$environment region=$TF_VAR_azure_region"
      # ansible-playbook playbooks/transactional-portal-api.yml  --extra-vars "owner=$TF_VAR_owner platform=$platform env=$environment region=$TF_VAR_azure_region"
      ansible-playbook playbooks/entity-evalution.yml  --extra-vars "owner=$TF_VAR_owner platform=$platform env=$environment region=$TF_VAR_azure_region"
      log_info_1 "Deployment completed for Journey on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} == "batch" ]]; then
      log_info "Start Deploying Journey on environment $environment"
      copy_ansible_vars_from_azure_blob
      copy_ansible_secret_vars_from_azure_blob
      cd ${PROJECT_ROOT}/ansible/
      chmod +x azure_rm.py
      ansible-playbook playbooks/batch-server.yml -i hosts --private-key=/root/.ssh/test.pem --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region"
      # ansible-playbook playbooks/batch-service.yml  --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region"
      log_info_1 "Deployment completed for Journey on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} = "tportal" ]]; then
      log_info "Start Deploying tportal on environment $environment"
      copy_ansible_vars_from_azure_blob
      copy_ansible_secret_vars_from_azure_blob
      cd ${PROJECT_ROOT}/ansible/
      chmod +x azure_rm.py
      ansible-playbook playbooks/keycloak.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region"
      ansible-playbook playbooks/transactional-portal-backoffice.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region"
      ansible-playbook playbooks/transactional-portal-web.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region"
      ansible-playbook playbooks/clockwork-sms-api.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region"
      ansible-playbook playbooks/experian-client.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region"
      ansible-playbook playbooks/transactional-portal-jobs.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region"
      ansible-playbook playbooks/imcalc-api.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region"
      ansible-playbook playbooks/imcalc-jobs.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region"
      ansible-playbook playbooks/payments-out-web.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region"
      ansible-playbook playbooks/payments-out-jobs.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region"
      # ansible-playbook playbooks/finance-automation.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region"
      log_info_1 "Deployment completed for tportal on environment $environment"
      exit
    # elif [[ "$run_command" == "--ansible" && ${application} = "finance-automation" ]]; then
    #   log_info "Start Deploying Finance Automation on environment $environment"
    #   copy_ansible_vars_from_azure_blob
    #   copy_ansible_secret_vars_from_azure_blob
    #   cd ${PROJECT_ROOT}/ansible/
    #   chmod +x azure_rm.py
    #   ansible-playbook playbooks/finance-automation.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region"
    #   log_info_1 "Deployment completed for Finance Automation on environment $environment"
    #   exit
    # elif [[ "$run_command" == "--ansible" && ${application} = "payments-out" ]]; then
    #   log_info "Start Deploying Payments Out on environment $environment"
    #   copy_ansible_vars_from_azure_blob
    #   copy_ansible_secret_vars_from_azure_blob
    #   cd ${PROJECT_ROOT}/ansible/
    #   chmod +x azure_rm.py
    #   ansible-playbook playbooks/payments-out-web.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region"
    #   # ansible-playbook playbooks/payments-out-jobs.yml --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region"
    #   log_info_1 "Deployment completed for Payments Out on environment $environment"
    #   exit
    elif [[ "$run_command" == "--ansible" && ${application} = "activemq" ]]; then
      log_info "Start Deploying Queuing System and mule on environment $environment"
      copy_ansible_vars_from_azure_blob
      copy_ansible_secret_vars_from_azure_blob
      cd ${PROJECT_ROOT}/ansible/
      chmod +x azure_rm.py
      ansible-playbook playbooks/azure-activemq-service.yml -i hosts --private-key=/root/.ssh/azure_key/id_rsa --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region"
      ansible-playbook playbooks/azure-muleesb.yml -i hosts --private-key=/root/.ssh/azure_key/id_rsa --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region"
      log_info_1 "Deployment completed for Queuing System and mule on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} = "website" ]]; then
      log_info "Start Deploying website on environment $environment"
      copy_ansible_vars_from_azure_blob
      copy_ansible_secret_vars_from_azure_blob
      cd ${PROJECT_ROOT}/ansible/
      chmod +x azure_rm.py
      ansible-playbook playbooks/wordpress.yml -i hosts --private-key=/root/.ssh/azure_key/id_rsa --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region"
      log_info_1 "Deployment completed for website on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} = "jenkins" ]]; then
      log_info "Start Deploying jenkins on environment $environment"
      copy_ansible_vars_from_azure_blob
      copy_ansible_secret_vars_from_azure_blob
      cd ${PROJECT_ROOT}/ansible/
      chmod +x azure_rm.py
      ansible-playbook playbooks/azure-jenkins.yml -i hosts --private-key=/root/.ssh/azure_key/id_rsa --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region"
      log_info_1 "Deployment completed for jenkins on environment $environment"
      exit
    elif [[ "$run_command" == "--ansible" && ${application} == "waf" ]]; then
      log_info_1 "Creating WAF for $TF_VAR_environment in Azure"
      copy_ansible_vars_from_azure_blob
      copy_ansible_secret_vars_from_azure_blob
      cd ${PROJECT_ROOT}/ansible/
      chmod +x azure_rm.py
      ansible-playbook playbooks/azure-application-gateway.yml  --extra-vars "owner=$owner platform=$platform env=$environment region=$TF_VAR_azure_region status=create"
      log_info "WAF created in environment" $environment
      exit
    else
      echo "Please pass appropriate parameter to run this script"
      usage
      exit
    fi
else
    echo "Please pass appropriate parameter to run this script"
    usage
    exit
fi
