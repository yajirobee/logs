---
layout: memo
title: zsh cheatsheet
---

# format of process time reports with the time keyword
The `time` keyword in zsh produces output in the format specified by the variable `TIMEFMT`.

See the documentation for the `TIMEFMT` variable in the `zshparam` manual.
e.g. manual of zsh 5.9 (x86_64-apple-darwin22.0)

```
TIMEFMT
       The format of process time reports with the time keyword.  The default is `%J  %U user %S system %P cpu %*E total'.  Recognizes the following escape sequences, although
       not all may be available on all systems, and some that are available may not be useful:

       %%     A `%'.
       %U     CPU seconds spent in user mode.
       %S     CPU seconds spent in kernel mode.
       %E     Elapsed time in seconds.
       %P     The CPU percentage, computed as 100*(%U+%S)/%E.
       %W     Number of times the process was swapped.
       %X     The average amount in (shared) text space used in kilobytes.
       %D     The average amount in (unshared) data/stack space used in kilobytes.
       %K     The total space used (%X+%D) in kilobytes.
       %M     The  maximum memory the process had in use at any time in kilobytes.
       %F     The number of major page faults (page needed to be brought from disk).
       %R     The number of minor page faults.
       %I     The number of input operations.
       %O     The number of output operations.
       %r     The number of socket messages received.
       %s     The number of socket messages sent.
       %k     The number of signals received.
       %w     Number of voluntary context switches (waits).
       %c     Number of involuntary context switches.
       %J     The name of this job.

       A star may be inserted between the percent sign and flags printing time (e.g., `%*E'); this causes the time to be printed in `hh:mm:ss.ttt' format (hours and minutes are
       only printed if they are not zero).  Alternatively, `m' or `u' may be used (e.g., `%mE') to produce time output in milliseconds or microseconds, respectively.
```
