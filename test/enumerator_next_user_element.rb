# The value of Enumerator#next is an element of what the Enumerator walks,
# so a method of the program's answers on it. The class-fact walk took the
# builtin's answer from the four families' share rows, where next is
# String's and Integer's successor (a builtin value), and the dispatch on
# the value had no arm for Greeter (#9620). peek, next_values and
# peek_values answer the same way; Thread#join answers its receiver.
class Greeter
  def greet = "Works"
end

greeters = Array.new(3) { Greeter.new }

def check(label)
  puts "#{label}: #{yield}"
rescue NoMethodError => e
  puts "#{label}: NoMethodError (#{e.message})"
end

check("Array#[]") { greeters[0].greet }
check("Enumerator#next (class)") { greeters.cycle.next.class }
check("Array#cycle then #next") { greeters.cycle.next.greet }
check("Array#each then #next") { greeters.each.next.greet }
e = greeters.each
check("Enumerator#peek") { e.peek.greet }
check("Enumerator#next_values") { e.next_values[0].greet }
t = Thread.new { Greeter.new }
check("Thread#join then #value") { t.join.value.greet }
