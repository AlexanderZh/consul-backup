# consul-backup

Bash script for [Consul](https://www.consul.io/) key-value backup, clean and restore.


```bash
bash backup-keys.sh

   Utility for consul keys dumping/restoring

       requires jq for json parsing: yum install jq or apt install jq

   Usage: backup-keys.sh http://<consul_addr>:<consul_port>/v1 <consul_subfolder> <dump|restore|clean> <dir_path>
```

Consul can be used for distributed systems configuration. This script helps to perform batch operations such as backup, clean and restore.

Each value is stored as json file and can be controlled using *git*

Here is a brief instruction below:

## 1. Backup:

- cleanup existing backup folders:

```bash
rm -rf _my-config-dir_
```

- run backup:

```bash
bash backup-keys.sh http://<my-consul-addr>:<port>/v1 "<_my-config-dir_>" dump .
```

Here **_my-config-dir_** indicates consul subfolder, all values are stored in separate files in local subfolders exactaly the same as in consul virtual folders. If you want to dump all consul keys leave _my-config-dir_ empty ("")

- after updating config files commit them (_--all_ - for commit removed files too):

```bash
git add * --all
git commit -m "removed stuff.json"
git push origin master
```

## 2. Restore:

- get latest version of config files from git

```bash
git pull origin master
```

- run restore from each subfolder:

```bash
bash backup-keys.sh http://<my-consul-addr>:<port>/v1 "<_my-config-dir_>" restore <_my-config-dir_>
```

## 3. Batch cleanup selected keys in consul
```bash
bash backup-keys.sh http://<my-consul-addr>:<port>/v1 "<_my-config-dir_>" clean
```

