# Chart: Bookstack

nothelm-chart for [Bookstack](https://www.bookstackapp.com/)

Current version is hardcoded for support with Hetzner and Hetzner volumes.

## Features

- Automatic Backup to Hetzner Storage Boxes
- Uses Hetzner Volumes
- OIDC support

## Used software

1. docker-stack-deploy for secret rotation (https://github.com/neuroforgede/docker-stack-deploy)
2. Hetzner Docker Volumes via costela/docker-volume-hetzner (see https://github.com/neuroforgede/swarmsible/tree/master/environments/test/test-swarm/stacks for a stack to install the driver)
3. davideshay/dockerautolabel to mark the docker swarm node that is running bookstack so that the data volume backup trigger container can be co-located on the same node as the bookstack container