# A path that does not exist raises Errno::ENOENT before anything is
# yielded, with or without a block, whatever ignore_error says.
require "find"

def try(label)
  yield
  puts "#{label}: no error"
rescue Errno::ENOENT => e
  puts "#{label}: #{e.class}"
end

missing = "/tmp/spinel_find_missing_#{Process.pid}"
seen = []
try("block") { Find.find(missing) { |f| seen << f } }
try("ignore_error") { Find.find(missing, ignore_error: true) { |f| seen << f } }
try("blockless") { Find.find(missing).to_a }
p seen
