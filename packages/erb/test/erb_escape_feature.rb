# `require "erb/escape"` gives ERB::Escape.html_escape, called on the module
# and taken as a method the way erubi and roda's erb_h take it.
require "erb/escape"

puts ERB::Escape.html_escape(%(<a href="x">'&'</a>))
puts ERB::Escape.html_escape(42)

class View
  define_method(:h, ERB::Escape.instance_method(:html_escape))
end
puts View.new.h("<b>&</b>")
