# `require "cgi/util"` -- the escape functions' feature name before Ruby
# 3.5, and so the one a library written for both sides of the split asks
# for when RUBY_VERSION (Spinel answers "3.2.0") is below it:
#
#   require "cgi/escape"
#   require "cgi/util" if RUBY_VERSION < "3.5"    # Loofah's HTML5 scrubber
#
# The same feature this package's `cgi.rb` defines.
require "cgi"
