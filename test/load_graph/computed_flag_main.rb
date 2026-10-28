# A require that stands as a statement sets the loaded flag of what it
# loads also where the file only defines things, or where it names a native
# library, when another require reads that flag: a later require of the
# same file or library, computed or literal, answers false, as CRuby's
# does, not true.
require_relative "computed_flag_defs"
require "time"
def pull(path) = require_relative(path)
def pull_lib(name) = require(name)
p pull("computed_flag_defs")
p require_relative("computed_flag_defs")
p pull_lib("time")
p require("time")
p flag_defs_helper
