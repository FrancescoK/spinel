# A method whose body ends in the raise of a constant defined nowhere answers
# no value: its C function is `void`. Its call went raw into a slot another
# site had typed -- a String or Integer parameter, a typed local, a String or
# Integer Array's element -- and the C did not build ("initializing 'const
# char *' with an expression of incompatible type 'void'"). It is evaluated
# for its raise now, and the slot takes its nil, which nothing reads. The
# element slots took an unresolved call's raise token (`Styler.render(1)`
# inline, an sp_RbVal) just as raw, and coerce it the same way.

def table(rows)
  Styler.render(rows)
end

def panel(title, body)
  "#{title}: #{body}"
end

def bump(n) = n + 1

class Report
  def table(rows) = Styler.render(rows)
  def self.table(rows) = Styler.render(rows)
  def show = panel("Self", table([3]))
end

Row = Struct.new(:name)

puts panel("Plain", "ok")
p bump(1)
p Row.new("r").name
puts panel("Fancy", table([1])) if ARGV.first == "fancy"

begin
  puts panel("Fancy", table([1]))
rescue NameError => e
  p e.class
end

begin
  p bump(table([2]))
rescue NameError => e
  p e.class
end

begin
  puts panel("Obj", Report.new.table([1]))
rescue NameError => e
  p e.class
end

begin
  puts panel("Cls", Report.table([1]))
rescue NameError => e
  p e.class
end

begin
  puts Report.new.show
rescue NameError => e
  p e.class
end

begin
  p Row.new(table([1]))
rescue NameError => e
  p e.class
end

s = "kept"
begin
  s = table([1])
rescue NameError => e
  p e.class
end
p s

strs = ["a"]
nums = [1]
begin; strs.push(table([1])); rescue NameError => e; p e.class; end
begin; strs << Styler.render(1); rescue NameError => e; p e.class; end
begin; strs[0] = table([1]); rescue NameError => e; p e.class; end
begin; strs.unshift(Styler.render(1)); rescue NameError => e; p e.class; end
begin; strs.insert(0, table([1])); rescue NameError => e; p e.class; end
begin; p(["b", Styler.render(1)]); rescue NameError => e; p e.class; end
begin; p(strs << table([1])); rescue NameError => e; p e.class; end
begin; nums.push(Styler.render(1)); rescue NameError => e; p e.class; end
begin; nums << table([1]); rescue NameError => e; p e.class; end
begin; nums[0] = Styler.render(1); rescue NameError => e; p e.class; end
begin; nums.unshift(table([1])); rescue NameError => e; p e.class; end
begin; p([2, table([1])]); rescue NameError => e; p e.class; end
# parenthesized
begin; nums.push((table([1]))); rescue NameError => e; p e.class; end
begin; strs << (table([1])); rescue NameError => e; p e.class; end
begin; puts panel("Paren", (table([1]))); rescue NameError => e; p e.class; end
p strs, nums
