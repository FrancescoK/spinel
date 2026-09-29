# `X.module_eval do ... end` as a statement of a class or module body, where
# X is that body's own class -- `self`, its constant, or a local that holds
# it -- reopens the body in place: the block's aliases and defs land on the
# class. cgi/escape.rb picks the target with
#   target = defined?(CGI::EscapeExt) && CGI::EscapeExt.method_defined?(:escapeHTML) ? CGI::EscapeExt : self
# (EscapeExt is an empty module when the C extension is absent, so the
# condition is decided at compile time) and aliases on it.

class CGI3
  module Escape; end
  include Escape
  extend Escape
  module EscapeExt; end
end

module CGI3::Escape
  def escapeHTML(s) = s.gsub("<", "&lt;")
  def unescapeHTML(s) = s.gsub("&lt;", "<")

  target = defined?(CGI3::EscapeExt) && CGI3::EscapeExt.method_defined?(:escapeHTML) ? CGI3::EscapeExt : self
  target.module_eval do
    alias escape_html escapeHTML
    alias h escapeHTML
    alias unescape_html unescapeHTML
  end

  self.module_eval do
    def bracket(s) = "[#{s}]"
  end
  CGI3::Escape.class_eval do
    def braces(s) = "{#{s}}"
  end
end

p CGI3.escapeHTML("<a>"), CGI3.escape_html("<b>"), CGI3.h("<c>")
p CGI3.unescape_html("&lt;d>"), CGI3.bracket("e"), CGI3.braces("f")
