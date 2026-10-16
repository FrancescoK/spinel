# module_function naming an alias makes the alias a method of the module
# object too. It looked for a def of the name, which an alias has none of,
# so `M.n` was refused ("no class in the program defines a class method").

module Utils
  def h(s) = s.gsub("&", "&amp;")
  alias_method :escape_html, :h
  alias esc h
  define_method(:escape, instance_method(:h))
  module_function :escape_html, :esc, :escape

  # the aliases keep the body they captured
  def h(s) = "redefined"
end

p Utils.escape_html("a&b"), Utils.esc("c&d"), Utils.escape("e&f")

class Page
  include Utils
  def show = escape_html("x&y") + " " + h("z")
end

p Page.new.show

# both the alias and its target module functions (ERB::Util's h)
module Both
  def html(s) = "<#{s}>"
  alias tag html
  module_function :tag, :html
end

p Both.tag("b"), Both.html("i")
