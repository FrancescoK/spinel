# Library code asks RubyGems to activate the gem that provides a path when
# a require or a load of it fails (irb's Locale: `redo if defined?(Gem) and
# Gem.try_activate(lc_path)`). A compiled program has no gem to activate, so
# the answer is false, as it is in CRuby for a path that no gem provides.
p Gem.try_activate("no/such/lc/error.rb")
p ::Gem.try_activate("no_such_feature")
