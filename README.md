# instant-reverse-proxy

## Prerequisites

* Route53 Hosted Zone
* IAM Role
  * `route53:ChangeResourceRecordSets` action
  * `route53:ListHostedZonesByName` action
* Security Group
  * 443 port/Outbound
* RSA Key Pair
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
