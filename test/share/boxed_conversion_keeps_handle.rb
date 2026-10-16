# itself, to_str, Kernel#String and unary + of a variable that holds a String
# the program changes in place answer that String, as to_s does, and so does
# a chain of them, where the value is boxed: a then block's value, a block
# answering through a conditional, a Symbol proc. Unary + of a frozen String
# answers a new one. nil answers itself as nil, to_s and String a new "", and
# to_str and unary + raise on it unless `&.` skips the call.
x = +"h"
x << "!"
p x.then { |q| q.itself }.equal?(x)
p x.then { |q| q.to_str }.equal?(x)
p x.then { |q| q.to_s }.equal?(x)
p x.then(&:itself).equal?(x)
p x.then(&:to_str).equal?(x)
p x.equal?(x.then { |q| q.itself })
z = x.then { |q| ARGV.empty? ? q.itself : 1 }
p z.equal?(x)
n = nil
n = x if ARGV.size > 5
begin
  p n.then { |q| q.to_str }
rescue NoMethodError => e
  p e.class
end
p n.then { |q| q&.to_str }
p n.then { |q| q.itself }
n = x if ARGV.empty?
p n.then { |q| q.to_str }.equal?(x)
p x.then { |q| q.itself.itself }.equal?(x)
p x.then { |q| q.to_s.to_s }.equal?(x)
p x.then { |q| q.to_str.itself }.equal?(x)
p x.then { |q| q.itself.to_s }.equal?(x)
n = nil
n = x if ARGV.size > 5
p n.then { |q| q.itself.to_s }
p n.then { |q| q.to_s.itself }
begin
  p n.then { |q| q.itself.to_str }
rescue NoMethodError => e
  p e.class
end
p x.then { |q| String(q) }.equal?(x)
p x.then { |q| +q }.equal?(x)
p x.then { |q| String(q.itself) }.equal?(x)
p n.then { |q| String(q) }
begin
  p n.then { |q| +q }
rescue NoMethodError => e
  p e.class
end
w = x.then { |q| q.itself }
w << "?"
p x
v = x.then { |q| +q }
v << "+"
p x
z = +"z"
z << "!"
z.freeze
u = z.then { |q| +q }
p u.equal?(z), u.frozen?
u << "?"
p z, u
