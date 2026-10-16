# define_method(:m, M.instance_method(:x)) with M another module: m runs M's
# x on the receiver. The call was left to the run time, which has no
# UnboundMethod to bind, and m was never defined (NoMethodError).

module Esc
  def html_escape(s) = s.gsub("&", "&amp;").gsub("<", "&lt;")
  def shout(s) = "#{s.upcase}!"
end

class Page
  define_method(:escape, Esc.instance_method(:html_escape))
  define_method("yell", Esc.instance_method(:shout))
end

p Page.new.escape("a&<b"), Page.new.yell("hi")

module Utils
  define_method(:escape_html, Esc.instance_method(:html_escape))
  module_function :escape_html
end

p Utils.escape_html("x&y")
