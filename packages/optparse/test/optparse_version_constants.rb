# Without a version or release set, OptionParser answers the program's
# top-level Version and Release constants, as CRuby does.
require "optparse"

Version = [2, 1]
RELEASE = "beta"

parser = OptionParser.new
parser.program_name = "tool"
p parser.version
p parser.release
p parser.ver
parser.version = "3.0"
p parser.ver
