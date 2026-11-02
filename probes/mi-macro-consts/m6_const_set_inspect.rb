module Tags
  def tag(c, text) = const_set(c, text.inspect)
end
class T
  extend Tags
  tag :ESC, "a\e#b"
  tag :PLAIN, "ab"
end
p T::ESC, T::PLAIN
