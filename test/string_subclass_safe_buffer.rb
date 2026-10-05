# ActiveSupport's SafeBuffer, self-contained: a String subclass with a flag
# ivar, concat / << overridden to escape their argument and then super into
# String#concat, + through dup, [] through a bare super with a rest, an alias
# that keeps String's own concat, initialize_copy keeping the flag, and a
# to_s answering self. The instance is the String (#7449): it grows in place,
# prints, interpolates and joins as its bytes.

module Escape
  TABLE = { "&" => "&amp;", "<" => "&lt;", ">" => "&gt;", '"' => "&quot;", "'" => "&#39;" }
  def self.html_escape(s)
    s.to_s.gsub(/[&<>"']/) { |m| TABLE[m] }
  end
end

class SafeBuffer < String
  alias original_concat concat

  def initialize(str = "")
    @html_safe = true
    super
  end

  def html_safe? = @html_safe

  def html_safe = self

  def concat(value)
    super(escape_arg(value))
  end
  alias << concat

  def safe_concat(value)
    raise "unsafe" unless html_safe?
    original_concat(value)
  end

  def +(other)
    dup.concat(other)
  end

  def [](*args)
    new_string = super
    return unless new_string
    buf = SafeBuffer.new(new_string)
    buf.instance_variable_set(:@html_safe, true)
    buf
  end

  def initialize_copy(other)
    super
    @html_safe = other.html_safe?
  end

  def to_s = self

  private

  def escape_arg(value)
    if value.is_a?(SafeBuffer) && value.html_safe?
      value
    else
      Escape.html_escape(value)
    end
  end
end

buf = SafeBuffer.new("<b>")
p buf, buf.html_safe?, buf.class
buf << "<i>"
buf.concat("&")
p buf
buf.safe_concat("<br>")
p buf
other = SafeBuffer.new("<em>")
buf << other
p buf
sum = buf + "<x>"
p sum, sum.class, sum.html_safe?, buf
sl = buf[0, 3]
p sl, sl.class, sl.html_safe?
p buf[100]
d = buf.dup
p d.html_safe?, d.class, d == buf, d.equal?(buf)
p buf.to_s.equal?(buf), buf.html_safe.equal?(buf)
puts buf
puts "#{buf}!"
p buf.length, buf.upcase.class
html = SafeBuffer.new
["a", "<b>", "c&d"].each { |s| html << s }
p html
p [buf, "x"].join(" | ")
