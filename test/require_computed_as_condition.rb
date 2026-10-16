# `if require(backend)` with a path known only at run time (metrics'
# Config#require_backend): a feature the program was compiled with is
# loaded already, which CRuby answers false; any other raises LoadError.

require "set"

def load_backend(name)
  if require(name)
    :loaded
  else
    :already
  end
rescue LoadError => e
  e.message
end

p load_backend("set")
p load_backend("no/such/lib")
r = require(["s", "et"].join)
p r
