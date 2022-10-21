#!/bin/bash

if [[ $# -ne 3 && $# -ne 4 ]]; then
  echo ""
  echo "   Utility for consul keys dumping/restoring"
  echo ""
  echo "       requires jq for json parsing: yum install jq or apt install jq"
  echo ""
  echo "   Usage: backup-keys.sh http://<consul_addr>:<consul_port>/v1 <consul_subfolder> <dump|restore|clean> <dir_path>" 
  echo ""
  exit 1
fi

echo "======================================="
echo "consul url: $1";
echo "consul folder: $2"
echo "mode: $3"
echo "dump/restore dir (optional): $4"


if [[ ("$3" != "dump") && ("$3" != "restore") && ("$3" != "clean")]]; then
  echo "Mode should be dump, restore or clean"
  exit 2
fi

code=$(curl --silent --output /dev/null --write-out  "%{http_code}\n"  "$1/kv/?keys")

if [[ $code -ne 200 ]]; then
   echo "Consul is not accessible"
   exit 3
fi


if [[ "$3" = "dump" ]]; then
 echo "ENTERING DUMP MODE"

 keys=$(curl --silent "$1/kv/?keys" | jq -r .[])
 rm -rf $4
 for key in $keys; do
  echo "Processing key: $key"
  raw_value=$(curl --silent "$1/kv/$key")
  if echo $raw_value | grep -q :null; then
     echo "creating folder $key"
     mkdir -p $4/$key
  else
     echo $raw_value | jq -r .[0].Value | base64 -d | jq -r . > $4/$key.json
     echo ""
  fi
 done

else
 if [[ "$3" = "restore" ]]; then
   echo "ENTERING RESTORE MODE"
   
   for key in $(find $4 -name '*.json')
   do
     echo "$key: " 
     curl --silent -XPUT "$1/kv/$2/${key%.*}" --data @$key
   done
   echo 'all files processed'
 
 else
   echo "GOING TO CLEAN MODE"
   
   echo "ALL keys from $2 WILL BE DELETED FROM CONSUL"
   read -rsn1 -p"continue? Y/N" choice;echo
   if [[ ("$choice" = "y") || ("$choice" = "Y") ]]; then

     keys=$(curl --silent "$1/kv/$2?keys" | jq -r .[])
     for key in $keys; do
        raw_value=$(curl --silent "$1/kv/$key")
        if echo $raw_value | grep -qv :null; then
          echo "Deleting $key: "
          curl --silent -XDELETE "$1/kv/$key"
        fi
     done
   fi
      
   
 fi

fi

echo '======================================'
echo 'COMPLETE'
echo '======================================'
exit 0
