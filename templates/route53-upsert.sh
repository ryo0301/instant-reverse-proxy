#!/bin/bash

readonly HOST="{{{host}}}"
readonly DOMAIN="{{{domain}}}."

echo "$(date):per-boot:route53:start"

public_ipv4=$(curl -s 169.254.169.254/latest/meta-data/public-ipv4)
hosted_zone_id=$(
  aws route53 list-hosted-zones-by-name \
    --dns-name "$DOMAIN" \
    --query "HostedZones[?Name=='$DOMAIN'].Id" \
    --output text
)

cat << EOJ | aws route53 change-resource-record-sets \
  --region ap-northeast-1 \
  --hosted-zone-id "${hosted_zone_id##/*/}" \
  --change-batch file:///dev/stdin
{
  "Changes" : [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${HOST}.${DOMAIN}",
        "Type": "A",
        "TTL": 60,
        "ResourceRecords": [
          {
            "Value": "${public_ipv4}"
          }
        ]
      }
    }
  ]
}
EOJ

echo "$(date) per-boot:route53:done"
