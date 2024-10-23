---
layout: blog
title: "Setup development environment on MacBook Pro"
tags: Development
---

Setup log of my new work MBP.

<!--end_excerpt-->

# Machine spec
- Model: 16" MacBook Pro with M3 Pro
- Spec: 12-Core CPU, 18-Core GPU, 36GB Unified Memory, 512GB SSD Storage

# Setup log
- Swap caps lock and control keys
  - Config location: System Settings > Keyboard (tab) > Keyboard Shortcuts (button) > Modifier Keys (tab)
  - [ref](https://support.apple.com/zh-sg/guide/mac-help/mchlp1011/mac)
- Configure terminal settings
  - Default
    - Profile: Pro
    - Font: SF Mono Regular 14
    - Background: color = black, opacity = 70%
    - Text: color = white
    - Window size: columns = 240, rows = 80
  - For presentation
    - New profile
    - Font: SF Mono Regular 24
    - Background: color = white, opacity = 100%
    - Text: color = black
    - Window size: columns = 240, rows = 80
- Install [homebrew](https://brew.sh/)
- Install [Inconsolata](https://fonts.google.com/specimen/Inconsolata) font
- Generate SSH keys and add `config` file
```sh
ssh-keygen -t ed25519
```
- Setup [dotfiles](https://github.com/yajirobee/dotfiles)
- Create local bin dir
```sh
mkdir -p ~/local/bin
```

## Java
Use [Eclipse Temurin](https://adoptium.net/)
```sh
brew install --cask temurin@21
brew install --cask temurin@17
brew install --cask temurin@11
```

Register for jenv
```sh
/usr/libexec/java_home -V  # check java home of installed jvms
jenv add /Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home
jenv add /Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home
jenv add /Library/Java/JavaVirtualMachines/temurin-11.jdk/Contents/Home
jenv global 21
```

## Kotlin
Install [kotlin command-line compiler](https://kotlinlang.org/docs/command-line.html)
```sh
brew install kotlin
```

## Python
Install the latest version
```sh
pyenv install -l
pyenv install 3.13.0
pyenv global 3.13.0
```
Use [Poetry](https://python-poetry.org/) for dependency management
```sh
curl -sSL https://install.python-poetry.org | python3 -
```
Create sandbox env to run ipython
```sh
cd ~/
poetry new pysandbox
cd pysandbox
poetry add ipython
poetry add matplotlib
poetry shell
ipython
```

## Ruby
Install the latest version
```sh
rbenv install -l
rbenv install 3.3.5
rbenv global 3.3.5
```

## Editors
## IntelliJ IDEA
- Install [IntelliJ IDEA](https://www.jetbrains.com/idea/download/)

### Configuration
- Font (Editor > Font): JetBrains Mono, size = 14.0
- Keybind (Preferences > Keymap)
  - Use "Emacs"
  - Type Hierarchy : remove ^H, add ^⌘H
  - Backspace add ^H
- Code Style (Preferences > Editor > Code Style)
  - Kotlin
    - Tabs and Indents > Continuation indent : 8 -> 4
    - imports > Top-Level Symbols / Java Statics and Enum Members : "Use single name import"
    - imports > Packages to Use Import with "*" : empty

## Containers
- Install Podman
```sh
brew install podman
```
- Create containers used for development
```sh
podman machine init
podman machine start
podman run --name dev-pg17 -p 5432:5432 \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_DB=test \
  -e POSTGRES_HOST_AUTH_METHOD=trust \
  -d postgres:17
podman run --name dev-mysql8 -p 3306:3306 -e MYSQL_ALLOW_PASSWORD=true -d mysql:8
```

## Misc
- Install [AWS CLI](https://aws.amazon.com/cli/)
- Install PostgreSQL
```sh
brew install postgresql@17
```
- Download [Trino CLI](https://trino.io/docs/current/client/cli.html)
```sh
mv ~/Downloads/trino-cli-462-executable.jar ~/local/bin/
chmod 755 ~/local/bin/trino-cli-462-executable.jar
ln -s ~/local/bin/trino-cli-462-executable.jar ~/local/bin/trino
```
