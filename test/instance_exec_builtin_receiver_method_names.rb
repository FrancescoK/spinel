# A receiverless call in a builtin receiver's instance_exec block binds to the
# receiver's own method ahead of a top-level def of that name, also when the
# block takes a keyword splat (the splice declines it).

def length = 99
def helper = "top"
h = {k: 1}
p "abc".instance_exec(5, **h) { |a, k: 1| [a, k, length, helper] }
p "abc".instance_exec(5, **h) { |a, k: 1| self.length }
p "abc".instance_eval { length }
p [1, 2].instance_exec(**h) { |k: 1| [k, length, frozen?] }
p [1, 2, 3].instance_eval { [length, frozen?] }
[[1, 2], "abc"].each { |x| p x.length }
