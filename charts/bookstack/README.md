# Chart: Bookstack

nothelm-chart for [Bookstack](https://www.bookstackapp.com/)

Built with Hetzner in mind, but will work in other deployments as well.

## Features

- Automatic Backup to SFTP (e.g. Hetzner Storage Boxes)
- Uses Hetzner Volumes
- OIDC support according to [this video](https://www.youtube.com/watch?v=CL5kMFkopHY)

## Used software

1. docker-stack-deploy for secret rotation (https://github.com/neuroforgede/docker-stack-deploy)
2. Hetzner Docker Volumes via costela/docker-volume-hetzner (see https://github.com/neuroforgede/swarmsible/tree/master/environments/test/test-swarm/stacks for a stack to install the driver)
3. davideshay/dockerautolabel to mark the docker swarm node that is running bookstack so that the data volume backup trigger container can be co-located on the same node as the bookstack container

## Installation of Prerequisites

0. Install docker-stack-deploy
1. Install nothelm.py

## How to use (with Hetzner)

Setup a values.yaml file

```yaml
bookstack_backup_sftp_known_hosts: |
  <contents of known hosts>

bookstack_domain: <your domain>

bookstack_mysql_placement_constraints:
  - node.labels.hetzner_location == nbg1

bookstack_app_placement_constraints: 
  - node.labels.hetzner_location == nbg1

bookstack_mysql_volume_config: 
  driver: hetzner-volume
  driver_opts:
    size: '25'
    fstype: ext4
bookstack_uploads_volume_config: 
  driver: hetzner-volume
  driver_opts:
    size: '10'
    fstype: ext4
bookstack_storage_uploads_volume_config: 
  driver: hetzner-volume
  driver_opts:
    size: '25'
    fstype: ext4
```

Furthermore, setup a secret_values.yaml as well:

```yaml
bookstack_mysql_password: <some-password>

bookstack_backup_mysql_sftp_user: <some user>
bookstack_backup_mysql_sftp_target: <some target>
bookstack_backup_mysql_ssh_password: <some password>

bookstack_backup_storage_sftp_user: <some user>
bookstack_backup_storage_sftp_target: <some target>
bookstack_backup_storage_ssh_password: <some password>

bookstack_oidc_client_id: <some client id>
bookstack_oidc_client_secret: <some secret>
bookstack_oidc_issuer: "<some oidc issuer>"
```

Then, deploy:

```bash
exec nothelm run deploy --project-dir <git-root>/charts/bookstack -f /path/to/values.yaml -f /path/to/secret_values.yaml
```
