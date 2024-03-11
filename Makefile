SHELL := /bin/bash

prereqs:
	brew install kind istioctl k9s

# will overwrite any changes to files
get-istio:
	curl -L https://istio.io/downloadIstio | sh -

create:
	kind create cluster --name kiali-cluster
	istioctl install --set profile=demo -y
	kubectl label namespace default istio-injection=enabled

step1:
	kubectl apply -f ./istio-*/samples/addons

step2:
	-kubectl create namespace bookinfo
	-kubectl label namespace bookinfo istio-injection=enabled
	kubectl apply -f ./istio-*/samples/bookinfo/platform/kube/bookinfo.yaml -n bookinfo

proxy:
	kubectl port-forward svc/kiali 20001:20001 -n istio-system

test:
	kubectl exec -it "$(kubectl get pod -l app=ratings -n bookinfo -o jsonpath='{.items[0].metadata.name}')" -n bookinfo -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>"

cleanup:
	kind delete cluster --name kiali-cluster

list-clusters:
	kind get clusters

