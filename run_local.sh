#!/bin/bash

SCRIPT_PATH=$(dirname "$(readlink -f "$0")")
PHEVAL_HOME=$SCRIPT_PATH

docker run \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $PHEVAL_HOME:$PHEVAL_HOME \
  -e PHEVAL_HOME=$PHEVAL_HOME \
  -e NXF_USRMAP=$(id -u) \
  ghcr.io/ebispot/grebi_nextflow:latest \
  bash -c "cd $PHEVAL_HOME && nextflow ./nextflow/main.nf \
    -c nextflow/local_nextflow.config -resume"

