# defined?(ERB::Escape) asks a library spinel provides from Ruby source
# (packages/erb): its constants are the ones that source defines. ERB has no
# Escape there, so the guard decides at compile time, and the def in its
# else branch is the method, not a choice the run time makes. Both branches
# escape the same way.
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

p Utils.escape_html("a&<b>\"c'")
p defined?(ERB::Util)
p defined?(ERB::Util::NoSuch)
