---
layout: memo
title: Study React
---

# Development environment
## Use nodejs & npm via docker
```
$ docker run -it --rm -v $(pwd):/app -w /app -e "PORT=3000" -p 8080:3000 -u node node:18-buster /bin/bash
```

## Use VScode dev containers
[Developing inside a Container](https://code.visualstudio.com/docs/devcontainers/containers#_quick-start-open-an-existing-folder-in-a-container)

Used the following `devcontainer.json`
```json
{
  "name": "react sandbox",
  "image": "mcr.microsoft.com/devcontainers/typescript-node",

  "customizations": {
    "vscode": {
      "extensions": ["streetsidesoftware.code-spell-checker"]
    }
  },

  "forwardPorts": [3000],
  "remoteUser": "node"
}
```

## Use Vite
[Vite](https://vitejs.dev/guide/) is a build tool for frontend development.

# Try React
## [StrictMode](https://react.dev/reference/react/StrictMode)
> <StrictMode> lets you find common bugs in your components early during development.
