# `require "cgi/escape"` -- the name Ruby 4.0 keeps for this surface. CRuby
# split the library: the request/response object left the default gems, and
# the escape functions stayed behind as `cgi/escape`, which is what code
# written for 4.0 (Loofah's HTML5 scrubber, for one) requires. It is the
# same feature this package's `cgi.rb` defines.
require "cgi"
