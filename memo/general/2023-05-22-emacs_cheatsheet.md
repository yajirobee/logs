---
layout: memo
title: Emacs cheatsheet
---

# General
## Evaluate a piece of elisp code
> - You can type the form in the *scratch* buffer, and then type LFD (or C-j) after it. The result of evaluating the form will be inserted in the buffer.
> - Typing M-: or M-x eval-expression allows you to type a Lisp form in the minibuffer which will be evaluated once you press RET.

- [Emacs manual](https://www.gnu.org/software/emacs/manual/html_node/efaq/Evaluating-Emacs-Lisp-code.html)

## enable / disable tabs instead of spaces on a buffer
set `indent-tab-mode` to `t` to enable tabs.

- [Tabs vs Spaces](https://www.gnu.org/software/emacs/manual/html_node/emacs/Just-Spaces.html)

# Major modes
## Markdown mode
- [markdown mode](https://github.com/jrblevin/markdown-mode)

### Table editing
- `C-c UP` or `C-c DOWN` - Move the current row up or down.
- `C-c LEFT` or `C-c RIGHT` - Move the current column left or right.
- `C-c S-UP` - Kill the current row.
- `C-c S-DOWN` - Insert a row above the current row. With a prefix argument, row line is created below the current one.
- `C-c S-LEFT` - Kill the current column.
- `C-c S-RIGHT` - Insert a new column to the left of the current one.

# Spacemacs
## Reinstall packages
remove packages under `elpa/` directory and restart emacs.

## Key binds
- list processes of Emacs subprocesses `M-m a p` (list-processes)

- [Key bindings conventions](https://develop.spacemacs.org/doc/CONVENTIONS.html#key-bindings-conventions)

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

### [Clangd](https://clangd.llvm.org/)

#### [Project setup](https://clangd.llvm.org/installation#project-setup)
```
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1
```

# Emacs for Mac
- [Emacs for OSX](https://emacsforosx.com/)
- [Emacs Mac Port](https://github.com/railwaycat/homebrew-emacsmacport)

# Trouble shooting
## Too many open files
This problem cannot be simply solved by increasing ulimit because

> Emacs uses pselect, which is limited to FD_SETSIZE file descriptors, usually 1024.

It requires to build Emacs to change `FD_SETSIZE`.

lsp-mode tends to consume many file descriptors for file watching.
[file-notify-rm-all-watches](https://www.gnu.org/software/emacs/manual/html_node/elisp/File-Notifications.html#index-file_002dnotify_002drm_002dall_002dwatches) can be used to free up descriptors as a workaound.

reference: [Fix annoying max open files for Emacs](https://en.liujiacai.net/2022/09/03/emacs-maxopenfiles/)

# Links
- [web page](https://www.gnu.org/software/emacs/)
- [Emacs News](https://emba.gnu.org/emacs/emacs/-/blob/master/etc/NEWS)
- [Awesome Emacs](https://github.com/emacs-tw/awesome-emacs)
- [Emacs 29 new features](https://www.grugrut.net/posts/202211242303/)
- [The Emacsmirror](https://emacsmirror.net/)
- [Keystrokes](https://www.gnu.org/software/emacs/manual/html_node/gnus/Keystrokes.html)
