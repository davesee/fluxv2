#!/usr/bin/env bash

helm template -f ./sources/rabbitmq/values.yaml ./sources/rabbitmq --namespace phoenix-stage >./kustomize/infra/rabbitmq.yaml

helm template -f ./sources/edgesql/values.yaml ./sources/edgesql --namespace phoenix-stage >./kustomize/infra/edgesql.yaml
