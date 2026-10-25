# OptionParser#warn and #abort print the message after the program name,
# $! by default. warn prints nothing when $VERBOSE is nil; abort raises
# SystemExit with status 1 and the printed line as its message.
require "optparse"

$stderr = $stdout
parser = OptionParser.new
parser.program_name = "prog"
parser.on("-n N", Integer)

parser.warn("careful")
begin
  parser.parse!(%w[-n])
rescue OptionParser::ParseError
  parser.warn
end

verbose = $VERBOSE
$VERBOSE = nil
parser.warn("hidden")
$VERBOSE = verbose

begin
  parser.abort("boom")
rescue SystemExit => e
  p [e.status, e.message]
end
begin
  begin
    parser.parse!(%w[--nope])
  rescue OptionParser::ParseError
    parser.abort
  end
rescue SystemExit => e
  p [e.status, e.message]
end
