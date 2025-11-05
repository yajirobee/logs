---
layout: memo
title: Kubernetes cheatsheet
---

# Nodes, Pods, Containers
- [Viewing Pods and Nodes](https://kubernetes.io/docs/tutorials/kubernetes-basics/explore/explore-intro/)

## Login a container
```sh
kubectl exec -it ${pod_name} -c ${container_name} -- /bin/bash

# login the default container
kubectl exec -it ${pod_name} -- /bin/bash
```

## Resource Management for Pods and Containers
[Resource Management for Pods and Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)

- Requests and limits
  - > If the node where a Pod is running has enough of a resource available, it's possible (and allowed) for a container to use more resource than its request for that resource specifies.
- CPU resource limit
  - `1.0` means 1 CPU unit (= 1 physical CPU core or 1 virtual core)
  - `1000m` (one thousand millicpu) = `1.0`

# Links
- [Kubernetes concepts (AWS EKS doc)](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-concepts.html)
- Switching contexts and namespaces: [kubectl & kubens](https://github.com/ahmetb/kubectx)
