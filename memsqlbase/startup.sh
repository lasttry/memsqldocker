#!/bin/bash

/usr/sbin/sshd

# catch the SIGTERM so we can safely stop the memsql-admin
trap '{  memsql-admin stop-node -ya; }' SIGTERM SIGINT SIGKILL

# finds the server by pinging it, needs the ping utility installed in container
find_server() {
  printf "Waiting for leaf ($1) .."
  c=0
  while ! ping -c 1 -n -w 1 $1 &> /dev/null
  do
    printf "%c" "."
    sleep 1
    let "c++"
    if [ $c -gt 20 ]; then
            echo "Couldn't reach the leaf ($1)"
            exit 1
    fi
  done
  echo ""
  echo "Leaf server found and ready!"
}

echo "Validating if the node is the Aggregator: $AGGREGATOR"
if [ "$AGGREGATOR" = "True" ]; then
  # checks if the memsql is already installed
  memsql-admin list-nodes | grep 'No nodes found' &> /dev/null
  if [ $? != 0 ]; then
    echo "memsql already installed - Starting services"
    memsql-admin start-node -ya
  else
    # we need to wait to confirm that the ssh is working on servers
    IFS=', ' read -r -a CLIENT_AGGREGATORS <<< "${ENV_CLIENT_AGGREGATORS}"
    IFS=', ' read -r -a LEAVES <<< "${ENV_LEAVES}"
    
    if [ ${#CLIENT_AGGREGATORS[@]} -gt 0 ]; then
      DEPLOY_CLIENT_AGGREGATORS+="--aggregator-hosts "
      for CLIENT_AGGREGATOR in ${CLIENT_AGGREGATORS[@]}; do
        find_server ${CLIENT_AGGREGATOR}
        DEPLOY_CLIENT_AGGREGATORS+="$CLIENT_AGGREGATOR,"
      done
      DEPLOY_CLIENT_AGGREGATORS="${DEPLOY_CLIENT_AGGREGATORS%?}"
    fi

    if [ ${#LEAVES[@]} -gt 0 ]; then
      DEPLOY_LEAVES="--leaf-hosts "
      for LEAF in ${LEAVES[@]}; do
        find_server ${LEAF}
        DEPLOY_LEAVES+="$LEAF,"
      done
      DEPLOY_LEAVES="${DEPLOY_LEAVES%?}"
    fi

    echo "run the command to create the aggregator."
    DEPLOY=(memsql-deploy setup-cluster -y -i /root/.ssh/id_rsa --license $LICENSE --master-host $AGGREGATOR_IP $DEPLOY_CLIENT_AGGREGATORS $DEPLOY_LEAVES --password $PASSWORD --allow-duplicate-host-fingerprints --version $VERSION)
    echo "${DEPLOY[@]}"
    "${DEPLOY[@]}"
  fi
  memsql-studio &
fi

# wait forever so we can catch the TRAP
while true
do
  tail -f /dev/null & wait ${!}
done
