# Struct.new / Data.define with a splatted constant, frozen or not, as
# regexp_parser builds `Token = Struct.new(*TOKEN_KEYS)`: the members are
# the constant's symbols.

class Regexp
  TOKEN_KEYS = %i[type token text].freeze
  Token = Struct.new(*TOKEN_KEYS) do
    def label = "#{type}:#{text}"
  end
end

POINT_KEYS = %i[x y]
Point = Data.define(*POINT_KEYS)

t = Regexp::Token.new(:literal, :literal, "a")
p t.type, t.text, t.label
p Regexp::Token.members
t.text = "b"
p t.to_a
p Point.new(x: 1, y: 2)
p Point.members
