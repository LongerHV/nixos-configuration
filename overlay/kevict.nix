{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "kevict";
  text = ''
    NAMESPACE=''${1-}
    if [ -z "$NAMESPACE" ]; then
            echo "Namespace is required"
            exit 1
    fi

    SELECTOR=''${2-}
    if [ -z "$SELECTOR" ]; then
            echo "Selector is required"
            exit 1
    fi

    pods=$(kubectl get pod -n "$NAMESPACE" -l "$SELECTOR" -o jsonpath={..metadata.name})

    IFS=' ' read -r -a podsList <<< "$pods"

    for pod in "''${podsList[@]}"
    do
            echo '{"apiVersion": "policy/v1", "kind": "Eviction", "metadata": {"namespace": "'"$NAMESPACE"'", "name": "'"$pod"'"}}' \
                    | kubectl create --raw "/api/v1/namespaces/$NAMESPACE/pods/$pod/eviction" -f -;
    done
  '';
}
