# `require "cgi/escape"` loads the same surface as `require "cgi"`: the
# feature name Ruby 4.0 keeps once the rest of the library left. And
# `cgi/util`, its name before 3.5, the way a library written for both
# sides of the split asks for them.
require "cgi/escape"
require "cgi/util" if RUBY_VERSION < "3.5"

puts CGI.escapeHTML(%(<a href="x">'&'</a>))
puts CGI.unescapeHTML("&lt;p&gt; &amp;amp; &#x41;&#66; &quot;")
puts CGI.escape("a b&c=d/é")
puts CGI.unescape("a+b%26c")
puts CGI.escapeURIComponent("a b")
