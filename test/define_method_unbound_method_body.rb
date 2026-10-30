# define_method given an UnboundMethod a call answers, as Rack::Utils
# defines escape_html from ERB::Escape's html_escape
module Esc
  def html_escape(s) = s.gsub("<", "&lt;")
end
class Page
  include Esc
  define_method(:escape_html, Esc.instance_method(:html_escape))
end
p Page.new.escape_html("<b>")
