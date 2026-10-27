# A require whose path is known only at run time (a variable) raises
# LoadError for a file the program was not compiled with, as CRuby does
# for one it cannot find; one the program was compiled with (it is compiled
# with every file it requires) is already loaded. It answered as if it had
# loaded anything, so a `rescue LoadError` fallback never ran. The
# LoadError's path is the feature the require was given, as in CRuby.
require_relative "computed_require_lib/helper"
require "set"

def load_adapter(name)
  path = "nonexistent/#{name.downcase}_adapter"
  require path
  :loaded
rescue LoadError => e
  [e.message, e.path]
end

def already(path)
  require path
  :already
end

p load_adapter("Nope")
p already("set"), already("set.rb")
p already(File.join(__dir__, "computed_require_lib", "helper"))
p Helper.hi
