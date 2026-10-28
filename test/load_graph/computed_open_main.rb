# A require whose path the compiler cannot read (a parameter, an expression
# that reads the environment) may name any file of the program. It runs the
# file the path names if the file has not run, and answers true; one that
# has answers false; a path naming no file of the program is a LoadError.
# A file whose require ran before the computed one stays where it ran:
# the alias below takes the method computed_open_lib defines, which the
# program could not tell if the computed require might have run the file
# first.
require_relative "computed_open_lib"
class OpenMoney
  alias_method :add, :+
end
def pull(path) = require_relative(path)
def never = require_relative("computed_open_late")
p pull("computed_open_lib")
p pull(File.join(__dir__, "computed_open_late"))
p pull("computed_open_late")
[1].each { p require_relative(ENV["SPINEL_TEST_NEVER_SET_XYZ"] || "computed_open_late") }
begin
  pull("computed_open_nowhere")
rescue LoadError => e
  p [e.class, e.path.end_with?("computed_open_nowhere")]
end
p OpenMoney.new(1).add(2).cents, OpenLate::V
