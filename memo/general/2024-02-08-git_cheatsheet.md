---
layout: memo
title: Git cheatsheet
---

# Undo with reflog
```sh
git reflog
git reset --hard HEAD@{1} # reset to 1 move ago
```

## Links
- [How to undo (almost) anything with Git](https://github.blog/2015-06-08-how-to-undo-almost-anything-with-git/)
- [gitrevisions](https://git-scm.com/docs/gitrevisions#Documentation/gitrevisions.txt-emltrefnamegtltngtemegemmaster1em)

# Global ignore config
The default localtion is `$XDG_CONFIG_HOME/git/ignore` or `$HOME/.config/git/ignore` if `$XDG_CONFIG_HOME` is not set.
