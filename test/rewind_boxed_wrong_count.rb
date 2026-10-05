# rewind given an argument on a boxed receiver. Enumerator#rewind and
# IO#rewind take none: CRuby evaluates the arguments, raises NoMethodError
# for a receiver that has no rewind (nil, an Integer), then ArgumentError.
# The boxed stream arm took the call whatever its count and answered the
# stream's sp_int into the boxed slot, so it did not build.
require "tmpdir"

def t(k)
  log = []
  path = File.join(Dir.tmpdir, "spinel_rewind_count_#{Process.pid}.txt")
  File.write(path, "ab")
  f = File.open(path)
  [[[1, 2].each, :x][k], [f, :x][k], [nil, 1][k], [7, 1][k]].each do |r|
    begin
      r.rewind((log << :a; 1))
    rescue ArgumentError, NoMethodError => e
      puts "#{e.class}: #{e.message}"
    end
  end
  e = [[1, 2].each, f][k]
  e.next
  p e.rewind.class
  p e.next
  g = [f, 1][k]
  g.read
  p g.rewind
  p g.read
  f.close
  File.delete(path)
  p log
end

t(ARGV.size)
