# Unary plus keeps a mutable receiver but copies a frozen receiver,
# including when freeze's result carries a shared String handle.
# spinel: gc-minor
# spinel: share
text = +"local"
other = text
other << "!"
same = +text
same << "?"
p [text, other, same.equal?(text)]
copy = +text.freeze
copy << "+"
p [text, other, copy, copy.equal?(text), text.frozen?, copy.frozen?]

class UnaryPlusFrozenReceiver
  def initialize
    @text = +"ivar"
  end

  def run
    other = @text
    other << "!"
    same = +@text
    same << "?"
    p [@text, other, same.equal?(@text)]
    copy = +@text.freeze
    copy << "+"
    p [@text, other, copy, copy.equal?(@text), @text.frozen?, copy.frozen?]
  end
end
UnaryPlusFrozenReceiver.new.run
