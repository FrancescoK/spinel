# defined?(ERB::Escape) asks a library spinel provides from Ruby source
# (packages/erb): its constants are the ones that source defines. ERB
# defines Escape there, as CRuby's erb does, so the guard decides at compile
# time for the define_method branch (instance_method of a method the module
# defines is true), and the def in the else branch is never a choice the run
# time makes. rack/utils guards its escape_html this way. A name the source
# does not define (ERB::NoSuch) decides the other way. Both branches escape
# the same way.
require "erb"

module Utils
  if defined?(ERB::Escape) && ERB::Escape.instance_method(:html_escape)
    define_method(:escape_html, ERB::Escape.instance_method(:html_escape))
  else
    def escape_html(s)
      ERB::Util.html_escape(s)
    end
  end
  module_function :escape_html
end

module Other
  if defined?(ERB::NoSuch)
    define_method(:escape_html, ERB::Escape.instance_method(:html_escape))
  else
    def escape_html(s)
      ERB::Util.html_escape(s)
    end
  end
  module_function :escape_html
end

p Utils.escape_html("a&<b>\"c'")
p Other.escape_html("<i>")
p defined?(ERB::Util)
p defined?(ERB::Escape)
p defined?(ERB::Util::NoSuch)
