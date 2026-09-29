# A module both included and extended into one class carries its aliases to
# the instance side and the class side. Calling the alias on an instance
# while the class side uses the original -- cgi's CGI::Escape, `extend`ed
# and `include`d into CGI, with escape_html aliasing escapeHTML -- left the
# instance copy of the original unemitted: the alias made its target live,
# but only when no copy of the target was live yet, and the class copy was.

module Esc
  def unescapeHTML(s) = s.gsub("&lt;", "<")
  alias unescape_html unescapeHTML
  def escapeHTML(s) = s.gsub("<", "&lt;")
  alias escape_html escapeHTML
  alias h escapeHTML
end

class K
  include Esc
  extend Esc
end

p K.unescapeHTML("&lt;a>")
p K.new.unescape_html("&lt;b>")
p K.h("<c>")
p K.new.h("<d>")
p K.new.escape_html("<e>")
p K.escape_html("<f>")
