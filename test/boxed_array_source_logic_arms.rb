# A local that holds an Array written through a logical operator, a begin or a
# rescue modifier (`x = f && [1, 2]`, `($f && [1, 2]) || [3]`), then given an
# element of another kind. The search for the arrays a pushed value must fit
# followed a boxed local through its `if`, `unless` and `case` writes, not
# these shapes, so the literal stayed an Array of Integers and the push raised
# "cannot store String into an Array[Integer]" where CRuby appends it. An arm
# that is left out or nil adds no array.
$f = true
x = ARGV.empty? && [1, 2]
x << "s"
p x

x = ($f && [1, 2]) || [3]
x << "s"
p x

x = nil || [1, 2]
x << "s"
p x

x = ARGV.empty? && [1, 2]
x << 3
x << "s"
p x

x = (ARGV.empty? and [1, 2])
x.push("s")
p x

x = (if ARGV.empty? then [1, 2] end)
x << "s"
p x

x = begin; ARGV.empty? ? [1, 2] : nil; rescue; [9]; end
x << "s"
p x

x = ([1, 2] if ARGV.empty?) || [3]
x << "s"
p x

x = (Integer("z") rescue [1, 2])
x << "s"
p x

x = ARGV.empty? && [1, 2]
y = x || [3]
y.push(:sym)
p y

x = case ARGV.size
    in 0 then [1, 2]
    in _ then nil
    end
x << "s"
p x

x = ((ARGV.empty? && [1, 2]))
x << "s"
p x

def logic_array(c) = c && [1, 2]
z = logic_array(true)
z << "s"
p z
