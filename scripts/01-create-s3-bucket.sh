#!/bin/bash
set -e

# Variables
BUCKET_NAME="quiz-arena-web-<quiz-arena-web-flopy2026>"
REGION="us-east-1"

echo "Verificando identidad AWS..."
aws sts get-caller-identity

echo "Creando bucket $BUCKET_NAME..."
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION"

echo "Bloqueando acceso público..."
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo "Aplicando Bucket owner enforced..."
aws s3api put-bucket-ownership-controls \
  --bucket "$BUCKET_NAME" \
  --ownership-controls Rules=[{ObjectOwnership=BucketOwnerEnforced}]

echo "Verificando configuración..."
aws s3api get-bucket-location --bucket "$BUCKET_NAME"
aws s3api get-public-access-block --bucket "$BUCKET_NAME"

echo "Listo. Bucket creado y privado."