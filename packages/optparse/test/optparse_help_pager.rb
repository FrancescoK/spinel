# --help on a terminal pipes the help through RUBY_PAGER, with " -Fe"
# added to LESS. IO#tty? is answered true so the test runs without one.
require "optparse"

class IO
  def tty?
    true
  end
end

ENV["RUBY_PAGER"] = "sh -c 'echo \"LESS=$LESS\"; sed s/^/paged:/'"
ENV["LESS"] = "-R"
parser = OptionParser.new do |opts|
  opts.banner = "Usage: prog [options]"
  opts.on("-x", "an x")
end
puts "before"
$stdout.flush
parser.parse!(%w[--help])
puts "not reached"
