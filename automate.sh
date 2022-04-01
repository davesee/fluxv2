#!/usr/bin/env bash

helm template -f ./sources/rabbitmq/values.yaml ./sources/rabbitmq --name-template=stage --namespace phoenix-stage >./kustomize/infra/rabbitmq.yaml

helm template -f ./sources/edgesql/values.yaml ./sources/edgesql --name-template=stage --namespace phoenix-stage >./kustomize/infra/edgesql.yaml

helm template -f ./sources/mssql/values.yaml ./sources/mssql --name-template=stage --namespace phoenix-stage >./kustomize/infra/mssql.yaml
