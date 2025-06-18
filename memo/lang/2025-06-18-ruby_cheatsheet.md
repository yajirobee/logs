---
layout: memo
title: Ruby cheatsheet
---

# Gems
- Install failure of mysql2 on mac : error "ld: library not found for -lzstd"
```sh
gem install mysql2 -- --with-ldflags=-L$(brew --prefix zstd)/lib
# or
bundle config build.mysql2 "-- --with-cflags=\"-Wno-error=implicit-function-declaration\" --with-ldflags=-L$(brew --prefix zstd)/lib"
```
