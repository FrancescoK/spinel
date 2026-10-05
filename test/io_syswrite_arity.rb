# IO#syswrite takes exactly one argument, where IO#write takes any number.
# Given two, syswrite was emitted as a write of each, and the statement text
# it made for an operand of another class than String did not build. CRuby
# evaluates the arguments, raises NoMethodError for a nil handle, then
# ArgumentError; one argument writes as before.
require "tmpdir"

def t(k)
  log = []
  path = File.join(Dir.tmpdir, "spinel_syswrite_arity_#{Process.pid}.txt")
  f = File.open(path, "w")
  begin
    f.syswrite((log << 1; 7), (log << 2; "x"))
  rescue ArgumentError => e
    p e.message
  end
  begin
    f.syswrite
  rescue ArgumentError => e
    p e.message
  end
  a = [1, :s][k]
  begin
    f.syswrite(a, nil)
  rescue ArgumentError => e
    p e.message
  end
  g = k == 0 ? nil : f
  begin
    g.syswrite("a", 1)
  rescue NoMethodError => e
    p e.class
  end
  p f.syswrite("ab")
  p f.syswrite(a)
  f.close
  p File.read(path)
  File.delete(path)
  p log
end

t(ARGV.size)
