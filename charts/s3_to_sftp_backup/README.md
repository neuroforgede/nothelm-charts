# s3_to_sftp_backup

Chart to backup s3 compatible storage to an sftp endpoint, e.g. a Hetzner Storage Box

## Required Software

- https://github.com/neuroforgede/docker-stack-deploy

## Usage

### Rclone password

To obtain the rclone password in the required form you can simply run:

```
rclone obscure <password>
```