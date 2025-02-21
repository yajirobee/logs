---
layout: memo
title: Kubernetes cheatsheet
---

# Switching contexts and namespaces
- [kubectl & kubens](https://github.com/ahmetb/kubectx)

# Login a container
```sh
kubectl exec -it ${pod_name} -c ${container_name} -- /bin/bash

# login the default container
kubectl exec -it ${pod_name} -- /bin/bash
```
