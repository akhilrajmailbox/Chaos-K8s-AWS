#!/bin/bash

if [[ ! -z "${CHAOS_NAMESPACE}" ]] && [[ ! -z "${CLUSTER_NAME}" ]] && [[ ! -z "${CLUSTER_REGION}" ]] ; then
export CHAOS_NAMESPACE=($CHAOS_NAMESPACE)
export CLUSTER_NAME=$CLUSTER_NAME
export CLUSTER_REGION=$CLUSTER_REGION



##########################################
function K8s_Login() {
	aws eks update-kubeconfig --name $CLUSTER_NAME --region $CLUSTER_REGION
}


##########################################
function Chaos_Run() {
	K8s_Login
	for INDI_CHAOS_NAMESPACE in ${CHAOS_NAMESPACE[*]} ; do
		echo "DEVOPS_NOTICE : $INDI_CHAOS_NAMESPACE is using from array of $CHAOS_NAMESPACE"
		DEPLOY_STATUS=$(kubectl -n $INDI_CHAOS_NAMESPACE get deploy -o json)
		DEPLOY_NAME=$(echo "$DEPLOY_STATUS" | jq -r '.items[].metadata.name')

		for INDI_DEPLOY_NAME in ${DEPLOY_NAME[*]} ; do
			INDI_DEPLOY_STATUS=$(kubectl -n $INDI_CHAOS_NAMESPACE get deploy $INDI_DEPLOY_NAME -o json)
			INDI_DEPLOY_REPLICA=$(echo "$INDI_DEPLOY_STATUS" | jq -r '.spec.replicas')
			if [[ $INDI_DEPLOY_REPLICA -gt 1 ]] ; then
				echo "$INDI_DEPLOY_NAME have $INDI_DEPLOY_REPLICA replica"
				DEL_DEPLOY_REPLICA=`expr $INDI_DEPLOY_REPLICA - 1`
				PODS_NAME=($(kubectl -n $INDI_CHAOS_NAMESPACE get pods --sort-by=.status.startTime | grep $INDI_DEPLOY_NAME | cut -d" " -f1 | head -n $DEL_DEPLOY_REPLICA))
				for i in ${PODS_NAME[*]} ; do
					echo "Chaos !!!! - $i"
					kubectl -n $INDI_CHAOS_NAMESPACE delete pods $i
					sleep 1
				done
			fi
		done
	done
}

else
	echo "CHAOS_NAMESPACE, CLUSTER_NAME and CLUSTER_REGION need to provide"
	echo "task aborting.....!"
	exit 1
fi


Chaos_Run
source /docker_entrypoint.sh