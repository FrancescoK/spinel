# The first Spinel run differs from CRuby; only the confirmation run fails.
# diff-test gives each invocation a private TMPDIR, and checks both the
# classification and the report of the second run's signal or timeout.
require "tmpdir"

if RUBY_ENGINE == "ruby"
  puts "reference"
else
  marker = File.join(Dir.tmpdir, "diff-confirmation-" + ARGV[0])
  if File.exist?(marker)
    File.delete(marker)
    if ARGV[0] == "crash"
      Process.kill("KILL", Process.pid)
    else
      sleep 5
    end
  else
    File.write(marker, "first run")
    puts "spinel"
  end
end
