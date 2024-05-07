---
layout: memo
title: C++ cheatsheet
---

# Symbol name mangling
- [Itanium C++ ABI Mangling](https://itanium-cxx-abi.github.io/cxx-abi/abi.html#mangling)
- [The Secret Life of C++: Symbol Mangling](http://web.mit.edu/tibbetts/Public/inside-c/www/mangling.html)
- [Mangling Basics](https://github.com/gchatelet/gcc_cpp_mangling_documentation)

## Demangle
- c++filt(1)
```sh
$ c++filt _Z1fv
f()
```
- nm(1) with `--demangle` option

# Links
- [C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines)
- [Rule of Zero](https://en.cppreference.com/w/cpp/language/rule_of_three#Rule_of_zero)
