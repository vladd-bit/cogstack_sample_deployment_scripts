#!/usr/bin/env bash
IMAGE_TAG="base_image_debian_dev"
IMAGE_VERSION="latest"

DOCKER_BASE_IMAGE=$PWD"/base_debian_dev_image.dockerfile"

docker build -t ${IMAGE_TAG}:${IMAGE_VERSION} . -f $DOCKER_BASE_IMAGE --force-rm
docker build -t cogstack:${IMAGE_VERSION} . -f $PWD"/cogstack.dockerfile" --force-rm

# Run the images by creating containers
#  # docker run --name base_image_debian_dev_container -d -it base_image_debian_dev 
# docker run --name cogstack -d -it cogstack 

# removes all dangling images, as they have no reference
#   docker rmi $(docker images -f "dangling=true" -q) --force
# newer version 
# docker image prune --force


# docker-compose up --renew-anon-volumes