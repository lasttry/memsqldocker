STR=''
MASTER_AGGREGATOR='172.16.0.1'
ENV_CLIENT_AGGREGATORS="172.16.0.2, 172.16.0.3"
ENV_LEAVES="172.16.0.11,172.16.0.12,172.16.0.13"

IFS=', ' read -r -a CLIENT_AGGREGATORS <<< "${ENV_CLIENT_AGGREGATORS}"

IFS=', ' read -r -a LEAVES <<< "${ENV_LEAVES}"

if [ ${#CLIENT_AGGREGATORS[@]} -gt 0 ]; then
  STR+=" --aggregator-hosts "
  for CLIENT_AGGREGATOR in ${CLIENT_AGGREGATORS[@]}; do
    STR+="$CLIENT_AGGREGATOR,"
  done
  STR="${STR%?}"
fi 

if [ ${#LEAVES[@]} -gt 0 ]; then
  STR+=" --leaf-hosts "
  for LEAF in ${LEAVES[@]}; do
    STR+="${LEAF},"
  done
  # Removes the last comma from the string
  STR="${STR%?}"
fi

echo "${STR}"

