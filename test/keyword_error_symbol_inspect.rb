# An unknown keyword's name reads as Symbol#inspect writes it: an operator
# method's name (`:+`, `:<=>`, `:[]=`, `:-@`, `:!`) and a `$`, `@` or `@@`
# name bare, like an identifier with its `?`, `!` or `=`, and anything else
# quoted. The message built at compile time quoted all but identifiers, so
# `f(a: 1, "+": 2)` raised `unknown keyword: :"+"`, where the run time's own
# Symbol#inspect already wrote `:+`.
def f(a:) = a
def t
  yield
rescue ArgumentError => e
  p e.message
end
t { f(a: 1, "+": 2) }
t { f(a: 1, "<=>": 2, "[]=": 3) }
t { f(a: 1, "-@": 1, "!": 2, "`": 3) }
t { f(a: 1, "$g": 1, "@iv": 2, "@@cv": 3) }
t { f(a: 1, "ok?": 1, "set=": 2, "a b": 3) }
t { f(a: 1, "+=": 1, "&&": 2, "=": 3) }
D = Data.define(:a)
t { D.new(a: 1, "+": 2) }
S = Struct.new(:a, keyword_init: true)
t { S.new(a: 1, "<<": 2) }
