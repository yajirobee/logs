---
layout: memo
title: Study React
---

# Use nodejs & npm via docker
```
$ docker run -it --rm -v $(pwd):/app -w /app -e "PORT=3000" -p 8080:3000 -u node node:18-buster /bin/bash
```

# Use Vite
[Vite](https://vitejs.dev/guide/) is a build tool for frontend development.
