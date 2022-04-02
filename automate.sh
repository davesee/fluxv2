#!/usr/bin/env bash

# Generate yaml from Helm charts
# https://helm.sh/docs/helm/helm_template/

main() {
    # create public chart yamls
    import_source infra rabbitmq https://charts.bitnami.com/bitnami bitnami/rabbitmq
    import_source monitoring grafana https://grafana.github.io/helm-charts grafana/grafana
    import_source monitoring prometheus https://prometheus-community.github.io/helm-charts prometheus-community/prometheus
    import_source monitoring kube-state-metrics https://prometheus-community.github.io/helm-charts prometheus-community/kube-state-metrics

    # create custom chart yamls
    helm template -f ./sources/edgesql/values.yaml ./sources/edgesql --name-template=edgesql --namespace patchme >./kustomize/base/infra/edgesql.yaml
}

import_source() {
    local base_type=$1
    local name=$2
    local helm_repo=$3
    local chart=$4

    # remove previous files
    rm -rf ./sources/$name ./kustomize/base/$base_type/$name.yaml
    mkdir -p ./sources/$name

    # add the repo and pull the chart
    silent=$(helm repo add $name $helm_repo)
    helm pull $chart -d ./sources/$name
    version=$(ls ./sources/$name)

    # create the complete chart in one yaml file
    helm template "./sources/$name/$version" --name-template=$name --namespace patchme >./kustomize/base/$base_type/$name.yaml
}

main
