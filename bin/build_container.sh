#!/bin/bash

docker buildx create --name mybuilder --use
docker buildx inspect mybuilder --bootstrap

# Build the image with caching options
  # --cache-to type=registry,mode=max,image-manifest=true,oci-mediatypes=true \
  # --cache-from type=registry \
docker buildx build \
  --platform linux/amd64 \
  --cache-to type=registry,ref=docker.io/jutonz/homepage-rb-build-cache:latest,mode=max,image-manifest=true,oci-mediatypes=true \
  --cache-from type=registry,ref=docker.io/jutonz/homepage-rb-build-cache:latest \
  --tag jutonz/homepage-rb:testin \
  --load \
  .
