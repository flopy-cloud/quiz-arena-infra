#!/bin/bash
set -e

# Variables (ya definidas en el paso anterior)
BUCKET_NAME="quiz-arena-web-flopy2026"
REGION="us-east-1"
ACCOUNT_ID="396633055478"
OAC_NAME="quiz-arena-oac"

echo "Paso 1: Creando Origin Access Control (OAC)..."
OAC_ID=$(aws cloudfront create-origin-access-control \
  --origin-access-control-config \
  Name="$OAC_NAME",SigningProtocol=sigv4,SigningBehavior=always,OriginAccessControlOriginType=s3 \
  --query 'OriginAccessControl.Id' \
  --output text)

echo "OAC creado con ID: $OAC_ID"

echo "Paso 2: Creando distribución CloudFront..."
DISTRIBUTION_CONFIG=$(cat <<EOF
{
  "CallerReference": "quiz-arena-$(date +%s)",
  "Comment": "Quiz Arena - distribucion privada con OAC",
  "DefaultRootObject": "index.html",
  "Enabled": true,
  "Origins": {
    "Quantity": 1,
    "Items": [
      {
        "Id": "S3-$BUCKET_NAME",
        "DomainName": "$BUCKET_NAME.s3.$REGION.amazonaws.com",
        "OriginAccessControlId": "$OAC_ID",
        "S3OriginConfig": {
          "OriginAccessIdentity": ""
        }
      }
    ]
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "S3-$BUCKET_NAME",
    "ViewerProtocolPolicy": "redirect-to-https",
    "AllowedMethods": {
      "Quantity": 2,
      "Items": ["GET", "HEAD"],
      "CachedMethods": {
        "Quantity": 2,
        "Items": ["GET", "HEAD"]
      }
    },
    "CachePolicyId": "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }
}
EOF
)

DISTRIBUTION_OUTP