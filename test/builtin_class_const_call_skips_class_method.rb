# A call on a core class's constant (File.basename, Integer.sqrt) runs that
# builtin's own class method, never a method of a program class of the same
# name: a constant receiver is a class, so no instance method of the name can
# be the one called. The reachability pass used to mark such a call by bare
# name, so every program method called `basename`, `join` or `sqrt` stayed
# alive in a class the program builds, with what it calls: Tempfile#open
# through the `File.open` of its own initialize. Registry is built here, so its
# instance methods wait only for a call that can reach them; Registry#basename,
# #join and #sqrt and the helpers they call are never run and are not emitted.
# The infer-test assertion checks the C. The answers are CRuby's.
class Registry
  def initialize(label)
    @label = label
  end

  def describe
    "registry #{@label}"
  end

  def basename(path)
    note_name(path)
  end

  def join(a, b)
    note_name(a + b)
  end

  def sqrt(n)
    note_root(n)
  end

  def note_name(path)
    @last = path
    path.size
  end

  def note_root(n)
    @last = n
    n
  end
end

reg = Registry.new("main")
puts reg.describe
a = Array.new(3) { |i| i * 2 }
h = Hash.new(0)
h[:x] += 2
s = String.new("abc")
s << "d"
puts a.inspect
puts h.inspect
puts s
puts Integer.sqrt(17)
puts File.basename("dir/file.rb")
puts File.join("dir", "file.rb")
puts ::Array.new(2, :z).inspect
