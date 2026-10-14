# In a class deriving from String, an alias of a String method named ahead
# of the class's own method of that name keeps String's: activesupport's
# SafeBuffer aliases concat as original_concat, then defines a concat that
# escapes, and safe_concat appends through the alias unescaped. The alias
# resolved by name to the class's own concat, which escaped again; an
# Array or Hash subclass already kept the builtin's.
class SafeBuffer < String
  def safe_concat(value)
    original_concat(value)
  end

  alias original_concat concat

  def concat(value)
    super(value.gsub("<", "&lt;"))
  end
  alias << concat
end

b = SafeBuffer.new("<b>")
b << "<i>"
b.safe_concat("<u>")
p b, b.length, b.class
