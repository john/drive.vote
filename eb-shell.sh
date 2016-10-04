#!/usr/bin/env bash
#
# Run on AWS Elastic Beanstalk instance to get a shell that can execute rails commands
# for the deployed code.
#
# Run this script from the app dir (/var/app/current) as root (sudo ./eb-console.sh)
#

set -xe

EB_SCRIPT_DIR=$(/opt/elasticbeanstalk/bin/get-config container -k script_dir)
EB_APP_DEPLOY_DIR=$(/opt/elasticbeanstalk/bin/get-config container -k app_deploy_dir)
EB_APP_USER=$(/opt/elasticbeanstalk/bin/get-config container -k app_user)
EB_SUPPORT_DIR=$(/opt/elasticbeanstalk/bin/get-config container -k support_dir)
EB_PID_DIR=$(/opt/elasticbeanstalk/bin/get-config container -k app_pid_dir)
EB_LOG_DIR=$(/opt/elasticbeanstalk/bin/get-config container -k app_log_dir)

. $EB_SUPPORT_DIR/envvars

. $EB_SCRIPT_DIR/use-app-ruby.sh

cd $EB_APP_DEPLOY_DIR

su -s /bin/bash $EB_APP_USER
