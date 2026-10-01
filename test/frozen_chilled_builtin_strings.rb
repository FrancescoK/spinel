# Strings CRuby answers frozen or chilled, and the `+s` that copies them
# (#6488). The engine's String constants (RUBY_VERSION, ...) are frozen, one
# object each, through a constant, a default argument and a block; so are
# String() of a boolean, a boxed boolean's inspect and a boxed class's
# #name. Symbol#to_s is chilled: not frozen, and a mutation goes through,
# but +@ copies it, through a typed Symbol, id2name, String(), map, a block,
# a boxed Symbol and a dynamic one, until its first mutation makes it plain.
# A String built fresh (inspect, interpolation, dup) is aliased by +@.
def al(s)
  t = +s
  t << "!"
  s
end
b = ARGV.size > 5
V = RUBY_VERSION
def plat(x = RUBY_PLATFORM) = x
def ruby_version = RUBY_VERSION.frozen?
p [V.frozen?, plat.frozen?, proc { RUBY_COPYRIGHT.frozen? }.call, RUBY_VERSION.equal?(V), ruby_version]
p [RUBY_ENGINE, RUBY_DESCRIPTION, RUBY_RELEASE_DATE, RUBY_REVISION, RUBY_ENGINE_VERSION].map(&:frozen?)
p [al(RUBY_ENGINE).end_with?("!"), (RUBY_ENGINE << "x" rescue $!.class), RUBY_VERSION.dup.frozen?, (+RUBY_PLATFORM).frozen?]
p [String(true).frozen?, String(b).frozen?, al(String(b)), [true, 1][0].inspect.frozen?]
kb = [Integer, 1][0]
p [kb.name.frozen?, al(kb.name), kb.to_s.frozen?, Integer.name.equal?(kb.name)]
e = :sym.to_s; f = +e; f << "z"; p [e, f, e.frozen?]
syms = [:p, :q]
sb = [:r, 1][0]
p [al(:sym.id2name), al(String(:sym)), al(syms.map(&:to_s)[0]), al(syms.map { |s| s.to_s }[1]), al(sb.to_s)]
p [al("dy#{syms.size}".to_sym.to_s), al(:sym.inspect), al("#{:sym}"), al(:sym.to_s.dup)]
m = :sym.to_s; m << "!"; n = +m; n << "?"; p [m, n, :sym.to_s]
