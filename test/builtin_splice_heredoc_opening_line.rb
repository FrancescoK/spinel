# The splice of a builtin library asks whether the program opens the
# module itself, from the offsets of the `module` keywords the lexer read.
# The lexer reads a heredoc's body before the rest of its opening line, so
# a `module` in the body's code came before a `module RbConfig` later on
# that line, and the lookup, which takes the offsets in order, missed the
# program's own definition.
LIMITS = <<~TEXT; module RbConfig
  #{def module = :kw}
TEXT
  LEVEL = 2
end
p LIMITS, RbConfig::LEVEL
