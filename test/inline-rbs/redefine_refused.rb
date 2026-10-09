# An annotated def replaced by a def whose own annotation the compiler
# refuses: `Wibble` is no class of this program. Neither annotation is
# applied, and each is reported -- the second for naming no type Spinel can
# pin, the first for being replaced by a definition without an applied
# annotation -- so neither takes part in agreement with --rbs either.
class K
  #: (Integer) -> Integer
  def m(x) = x
  #: (Wibble) -> Wibble
  def m(x) = x
end

p K.new.m("s")
