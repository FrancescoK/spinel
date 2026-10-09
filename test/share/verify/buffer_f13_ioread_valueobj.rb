require "tmpdir"
path = File.join(Dir.tmpdir, "share_verify_acc_#{Process.pid}.txt")
File.write(path, "XYZ")
class Acc
  def initialize; @b = String.new; end
  def add(f) = f.read(2, @b)
  def b = @b
end
acc = Acc.new
File.open(path) { |f| acc.add(f) }
p acc.b
class Acc2
  def initialize; @b = String.new; end
  def add(s) = @b.concat(s)
  def b = @b
end
acc = Acc2.new
acc.add("q")
p acc.b

File.delete(path)
