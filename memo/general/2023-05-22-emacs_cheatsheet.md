---
layout: memo
title: Emacs cheatsheet
---

# General
## Evaluate a piece of elisp code
> - You can type the form in the *scratch* buffer, and then type LFD (or C-j) after it. The result of evaluating the form will be inserted in the buffer.
> - Typing M-: or M-x eval-expression allows you to type a Lisp form in the minibuffer which will be evaluated once you press RET.

- [Emacs manual](https://www.gnu.org/software/emacs/manual/html_node/efaq/Evaluating-Emacs-Lisp-code.html)

# Spacemacs
## Reinstall packages
remove packages under `elpa/` directory and restart emacs.

## LSP
### [Metals](https://scalameta.org/metals/docs/editors/emacs/)
#### Bloop with gradle
Add [gradle-bloop](https://github.com/scalacenter/gradle-bloop) plugin. e.g.

- settings.gradle.kts
```
buildscript {
    repositories {
        mavenCentral()
    }

    dependencies { classpath("ch.epfl.scala:gradle-bloop_2.12:1.5.6") }
}
```
- build.gradle.kts
```
plugins {
    bloop
}
```

https://scalacenter.github.io/bloop/docs/build-tools/gradle

#### Log location
- `${project_home}/.metals/metals.log`

#### Reinstall metals
Delete `.cache/lsp/metals/` and install server again.

# Links
- [web page](https://www.gnu.org/software/emacs/)
- [Emacs News](https://emba.gnu.org/emacs/emacs/-/blob/master/etc/NEWS)
- [Awesome Emacs](https://github.com/emacs-tw/awesome-emacs)
- [Emacs 29 new features](https://www.grugrut.net/posts/202211242303/)
