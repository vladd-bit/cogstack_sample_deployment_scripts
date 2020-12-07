FROM roboxes/rhel8:latest

ARG TAG=redhat_latest
ARG CODE_VERSION=latest
LABEL maintainer="TEAM" \
      version=1.0 \
      TAG=redhat_latest

# entry command
CMD "/bin/sh"