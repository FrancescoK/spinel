# A require_relative whose path is built from the file's own directory and
# literals is a path known at compile time: it loads as the literal path
# would (#10146). CRuby prints each file as it loads.
require_relative __dir__ + "/require_dir_head_files/da"
require_relative File.join(__dir__, "require_dir_head_files", "db")
require_relative File.expand_path("require_dir_head_files/dc", __dir__)
require_relative(__dir__ + "/require_dir_head_files/dg") if true
require_relative "#{__dir__}/require_dir_head_files/dh"
require_relative __dir__ + "/require_dir_head_files/" + "di" + ".rb"

# an autoload takes its path from the same forms
autoload :DirJ, File.join(__dir__, "require_dir_head_files", "dj")
p DirJ::V

# `File.dirname(__FILE__)` is the same directory (relative to the working
# directory when the file is run by a relative path, so CRuby would not find
# it from here): in methods that are never called, the files do not load
def later
  require_relative File.dirname(__FILE__) + "/require_dir_head_files/df"
  require_relative File.join(File.dirname(__FILE__), "require_dir_head_files/dd")
  require_relative File.expand_path("require_dir_head_files/de", File.dirname(__FILE__))
  require_relative File.dirname(__FILE__) + "/require_dir_head_files/" + "df"
end

# any other computed path is only known when the call runs: it raises
# LoadError there, and compiles where it is never reached
def never(base)
  require_relative base + "/x"
end
base = File.join(__dir__, "no_such_dir")
begin
  require_relative base + "/x"
rescue LoadError
  puts "LoadError"
end
puts "main"
