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

# Links
- [Kubernetes concepts (AWS EKS doc)](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-concepts.html)
- Switching contexts and namespaces: [kubectl & kubens](https://github.com/ahmetb/kubectx)
