# A name computed at run time, sent to a boxed value, reaches the builtin
# method the value's class answers, as it reaches a typed receiver's.
class Box
  def size = 99
  def label(x) = "box #{x}"
end

m = ("si" + "ze").to_sym
p [:abc, "ab"].map(&m)   # (Integer#size is the word size: 8, or 4 on a 32-bit target)
x = [1, "ab"][1]
p x.send(m)
p({a: 1}.map(&m))
p [[1, 2], [3]].map(&m)
p [Box.new, "abc", [1]].map(&m)

# with an argument: a builtin's at that count, beside the program's own
j = ("lj" + "ust").to_sym
p ["ab", 7][0].send(j, 4)
l = ("lab" + "el").to_sym
p [Box.new, 1][0].send(l, 2)
inc = ("inc" + "lude?").to_sym
p [[1, 2], "xyz"].map { |v| v.send(inc, v.is_a?(String) ? "y" : 2) }

# a name no class of the value answers is still NoMethodError
q = ("no_such" + "_meth").to_sym
begin
  [1, "ab"][1].send(q)
rescue NoMethodError => e
  p e.message
end
