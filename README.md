# instant-reverse-proxy

Automatic HTTPS by Caddy2. \
Automatic registration to Route53. \
Stop at specified time after ssh session is disconnected.

## Prerequisites

* Route53 Hosted Zone
* IAM Role
  * `route53:ChangeResourceRecordSets` action
  * `route53:ListHostedZonesByName` action
* Security Group
  * 443 port/Inbound
* RSA Key Pair for remote port forwarding
* (Optional) EC2 Launch Template

## Run

```
$ git clone https://github.com/ryo0301/instant-reverse-proxy
$ cat <<EOF > .env
HOST_NAME=my
HOSTED_ZONE_DOMAIN=proxy.example.com
CADDY_DL_URL=https://github.com/caddyserver/caddy/releases/download/v2.0.0-beta.15/caddy2_beta15_linux_amd64
SHUTDOWN_TIMER_HOUR=1
UPSTREAM_PORT=3000
LOCALE=ja_JP.UTF-8
TIMEZONE=Asia/Tokyo
EOF
$ npm run generate -s 2> /dev/null | aws ec2 run-instances --launch-template LaunchTemplateName=reverse-proxy --user-data file:///dev/stdin
```

## Connect

When using SessionManager
```
$ cat <<EOF >> ~/.ssh/config
Host i-* mi-*
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
EOF
```

Generate Key pair and Send public key.
```
$ ssh-keygen -t rsa -b 4096
$ aws ec2-instance-connect send-ssh-public-key --instance-id i-XXXXXX --instance-os-user ec2-user --availability-zone ap-northeast-1a --ssh-public-key file:///$HOME/.ssh/id_rsa.pub
```

Remote port forwarding.
```
$ ssh -i ~/.ssh/id_rsa -l ec2-user i-XXXXXX -N -R 3000:localhost:3000
```