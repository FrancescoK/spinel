# A push onto the Array a builtin answers for a boxed receiver stores what
# CRuby's Array stores: `x.to_s.scan(/\d+/) << 99`, where another class's
# to_s and scan make the call a dispatch, holds the Integer beside the
# Strings rather than raising. A program's own method of the name answers
# its own Array, which the push widens where it is built.

class Piece
  def scan(_re) = ["x"]
  def keys = [:k]
end

class Label
  def to_s = Piece.new
end

def version_of(name)
  (name.to_s.scan(/\d+/) << 99).join(".")
end

def tagged(s)
  s.scan(/\d+/).push(1.5, :t, nil).inspect
end

def same_kind(s)
  (s.scan(/\d+/) << "z").inspect
end

def dropped(s)
  s.scan(/\d+/) << 1
  s.scan(/\d+/).push(2)
  :done
end

def keyed(h)
  (h.keys << "z").inspect
end

p version_of(:V1_9_3)
p version_of("V4_0_7")
p version_of(Label.new)
p tagged("a1b22"), tagged(Piece.new)
p same_kind("a1b22"), same_kind(Piece.new)
p dropped("a1"), dropped(Piece.new)
p keyed({ a: 1 }), keyed({ 1 => 2 }), keyed(Piece.new)
