#!/bin/bash

ACCOUNTS_FILE="accounts.txt";

#. Role to be used to generate temporary credentials .#
ROLE="AWSControlTowerExecution"

#. Run the cli command .#
function cli_run()
{
	AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN} \
	aws s3 ls
  #Change 'aws s3 ls' to your command

	unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
}


for ACCOUNT in `cat ${ACCOUNTS_FILE}`;do

	echo -e "Account: ${ACCOUNT}";

	SESSION_NAME="local_$(date +%d-%m-%Y@%H-%M)";

	ASSUME_ROLE=$(AWS_ACCESS_KEY_ID="ADD-YOUR-MASTER-CREDENCIAL" \
        AWS_SECRET_ACCESS_KEY="ADD-YOUR-MASTER-CREDENCIAL" \
        AWS_SESSION_TOKEN="ADD-YOUR-MASTER-CREDENCIAL" \
        aws sts assume-role --role-arn arn:aws:iam::${ACCOUNT:-NULL}:role/${ROLE:-NULL} --role-session-name "${SESSION_NAME}")

	AWS_ACCESS_KEY_ID=$(echo -e "${ASSUME_ROLE}" | grep AccessKeyId | cut -d\" -f4)
	AWS_SECRET_ACCESS_KEY=$(echo -e "${ASSUME_ROLE}" | grep SecretAccessKey | cut -d\" -f4)
	AWS_SESSION_TOKEN=$(echo -e "${ASSUME_ROLE}" | grep SessionToken | cut -d\" -f4)

	if [[ -z ${AWS_ACCESS_KEY_ID} ]] || [[ -z ${AWS_SECRET_ACCESS_KEY} ]] || [[ -z ${AWS_SESSION_TOKEN} ]];then
		echo "Unable to get temporary credencial"
		exit
	fi

	## Print the Account infos, it is necessary to check if the credencials are working.
	if ! AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN} aws sts get-caller-identity;then
	  echo -e "Error running aws sts"
	  exit
	fi

	cli_run;
done
