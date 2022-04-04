#!/usr/bin/env bash

# Generate yaml from Helm charts for use with Kustomize
# https://helm.sh/docs/helm/helm_template/

export prefix="phoenix"
export pass="vmuTaXjX5QMQTy=="

main() {
    # create public chart yamls
    import_source infra rabbitmq https://charts.bitnami.com/bitnami bitnami/rabbitmq \
        "service.type=LoadBalancer,metrics.enabled=true,networkPolicy.enabled=true,ingress.enabled=true,ingress.selfSigned=true,auth.username=phoenix,auth.password=$pass"
    import_source monitoring grafana https://grafana.github.io/helm-charts grafana/grafana \
        "service.type=LoadBalancer,testFramework.enabled=false,image.pullSecrets[0]=ase-ecr-credentials,adminPassword=$pass"
    import_source monitoring prometheus https://prometheus-community.github.io/helm-charts prometheus-community/prometheus \
        "server.service.type=LoadBalancer,nodeExporter.enabled=false,pushgateway.enabled=false,alertmanager.enabled=false,imagePullSecrets[0].name=ase-ecr-credentials"

    # create custom chart yamls
    helm template -f ./sources/edgesql/values.yaml ./sources/edgesql --name-template="edgesql" --namespace patchme \
        --set "sqldb.fullnameOverride=$prefix-edgesql" >./kustomize/bases/infra/edgesql.yaml
}

import_source() {
    local base_type=$1
    local name=$2
    local helm_repo=$3
    local chart=$4
    local vars=$5

    # remove previous files
    rm -rf ./sources/$name ./kustomize/bases/$base_type/$name.yaml
    mkdir -p ./sources/$name

    # add the repo, pull the chart, and set vars
    silent=$(helm repo add $name $helm_repo)
    helm pull $chart -d ./sources/$name
    silent=$(helm repo remove $name)

    version=$(ls ./sources/$name)
    if [[ -n $vars ]]; then set_vars="--set $vars"; else set_vars=""; fi

    # create the complete chart in one yaml file
    helm template "./sources/$name/$version" --name-template="$prefix-$name" --namespace patchme $set_vars >./kustomize/bases/$base_type/$name.yaml

    # optional remove sources
    # rm -rf ./sources/$name
}

main
