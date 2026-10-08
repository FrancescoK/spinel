# CRuby refuses to load this: "Errno is not a class (TypeError)".
# Errno is a builtin module that holds the system error classes, so
# `class Errno` cannot reopen it.
# spinel: reject-builtin-module: Errno is not a class (TypeError)
class Errno
end

puts Errno.class
