# Concat captures the receiver before any argument can replace its slot.
class ConcatSnapshot
  def run
    @text = +"old"
    original = @text
    original << "!"
    result = @text.concat(rebind, "z" * 100)
    p result, original, @text
  end
  def rebind
    @text = +"new"
    "first"
  end
end
ConcatSnapshot.new.run

s = +"local"
old = s
old << "!"
result = s.concat((s = +"new"; "x"), "y" * 100)
p result, old, s
