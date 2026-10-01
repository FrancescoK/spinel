# With no banner, OptionParser names the program without its extension.
require "optparse"

parser = OptionParser.new
p parser.banner == "Usage: #{File.basename($0, '.*')} [options]"
p parser.to_s.start_with?("Usage: ")
