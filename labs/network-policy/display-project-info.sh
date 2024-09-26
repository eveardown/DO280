#!/usr/bin/env bash

function display_divider() {
    printf '=%.0s' {1..80}; printf '\n'
}
export -f display_divider

function count_resources() {
    declare resource="${1:?You must specifiy the resource type}"

    declare -i count=-1
    ((count=$(oc get "${resource}" -o yaml | yq -r '.items | length')))

    [[ $((count)) -gt 0 ]] && return 0

    echo "INFO: There are no ${resource} in the project."
    return 1
}
export -f count_resources

function display_project_name() {

    declare -i status=0
    declare project=
    if project="$(oc project --short 2>/dev/null)"; then
        echo -e "\n\nPROJECT: ${project}"
    else
        ((status=1))
        echo "ERROR: No project has been set."
    fi
    return $((status))
}
export -f display_project_name

function display_pods() {

    if count_resources pods ; then
        echo -e "\n"
        oc get pods -o custom-columns='POD NAME:.metadata.name,IP ADDRESS:.status.podIP'
    fi
}
export -f display_pods

function display_services() {
    if count_resources services ; then
        echo -e "\n"
        oc get services -o custom-columns='SERVICE NAME:.metadata.name,IP ADDRESS:.spec.clusterIP'
    fi
}
export -f display_services

function display_routes() {
    if count_resources routes ; then
        echo -e "\n"
        oc get routes -o custom-columns='ROUTE NAME:.metadata.name,HOST NAME:.spec.host, PORT:.spec.port.targetPort'
    fi
}
export -f display_routes

function display_network_policies {

    if count_resources networkpolicies ; then
        echo -e "\n"
        oc get networkpolicies
    fi
}
export -f display_network_policies

function display_project_info {

    display_divider

    if display_project_name; then

        display_pods

        display_services

        display_routes

        display_network_policies
    fi

    display_divider
}
export -f display_project_info
watch -x -n 5 bash -c display_project_info
