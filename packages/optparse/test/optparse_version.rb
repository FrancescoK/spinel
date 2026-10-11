# OptionParser#version, #release, #program_name and #ver, as RDoc's
# `--version` switch prints them (`puts opt.version`).
require "optparse"

parser = OptionParser.new
p parser.version
p parser.release
p parser.ver

parser.version = "7.0.3"
p parser.version

parser.program_name = "rdoc"
p parser.program_name
p parser.ver

parser.release = "2026-10-11"
p parser.release
p parser.ver

shown = OptionParser.new do |opt|
  opt.version = "1.2"
  opt.program_name = "tool"
  opt.on("--version", "-v", "print the version") do
    puts opt.version
    puts opt.ver
  end
end
shown.parse!(["-v"])
