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
- remove blacklist
```
M-x lsp-workspace-blacklist-remove
```

### [Metals](https://scalameta.org/metals/docs/editors/emacs/)
#### Bloop with gradle
- Add [gradle-bloop](https://github.com/scalacenter/gradle-bloop) plugin. e.g. on `build.gradle.kts`

```kotlin
buildscript {
    repositories {
        mavenCentral()
    }

    dependencies { classpath("ch.epfl.scala:gradle-bloop_2.12:1.6.0") }
}

apply(plugin = "bloop")
```

- Export build (done by metals)
```sh
$ ./gradlew bloopInstall
```

- Verify installation and export
```sh
$ bloop projects
```

- Reference
  - [Bloop with Gradle](https://scalacenter.github.io/bloop/docs/build-tools/gradle)

#### Log location
- `${project_home}/.metals/metals.log`

#### Reinstall metals
Delete `.cache/lsp/metals/` and install server again.

# Links
- [web page](https://www.gnu.org/software/emacs/)
- [Emacs News](https://emba.gnu.org/emacs/emacs/-/blob/master/etc/NEWS)
- [Awesome Emacs](https://github.com/emacs-tw/awesome-emacs)
- [Emacs 29 new features](https://www.grugrut.net/posts/202211242303/)
- [The Emacsmirror](https://emacsmirror.net/)
- [Keystrokes](https://www.gnu.org/software/emacs/manual/html_node/gnus/Keystrokes.html)
