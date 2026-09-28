# A block keyword parameter named like an outer local gets its own slot:
# binding it leaves the outer local alone, on every path that binds block
# keywords by name.

k = 0
j = 0
r = 0

# yield
def y1 = yield(k: 1)
y1 { |k: 5| p k }
p k

def y2 = yield(k: 1, j: 2, z: 3)
y2 { |k:, j: 9, **r| p [k, j, r] }
p [k, j, r]

# block.call on a captured block
def run(&b) = b.call(k: 10)
p(run { |k: 1| k })
p k

# a stored block called later, with **rest beside the keyword
def cap(&b) = b
b = cap { |k:, **o| [k, o] }
p b.call(k: 8, z: 1)
p b.call(**{k: 5})
p k

# proc and lambda call
pr = proc { |k: 3, j: 4| [k, j] }
p pr.call(k: 7), pr.call, pr.(j: 1)
l = ->(k:, **o) { [k, o] }
p l.call(k: 1, z: 2)
p [k, j]

# nested blocks, each with its own k
def y3(**kw) = yield(**kw)
y3(k: 1) { |k:| y3(k: 2) { |k:| p k }; p k }
p k

# a missing required keyword names the keyword as written
def y4 = yield(q: 4)
begin
  y4 { |q:, k:| p k }
rescue ArgumentError => e
  p e.message
end

# builtin iterators
[1, 2].each { |x, k: 5| p [x, k] }
p [1, 2].map { |x, k: 5| x + k }
[1].each { |x, k: 3, **r| p [x, k, r] }
begin
  [1].each { |x, k:| p k }
rescue ArgumentError => e
  p e.message
end
p [k, r]

# instance_exec with keywords
class C; end
p C.new.instance_exec(k: 4) { |k:| k * 2 }
p C.new.instance_exec(k: 5) { |k: 1| k + 1 }
p k

# a keyword that shadows nothing
y4 { |q: 1| p q }
p C.new.instance_exec(w: 5) { |w: 1| w + 1 }

# a nested block's block-local of the same name is its own variable
q = 0
[1].each { |q| [2].each { |b; q| q = 9; p q }; p q }
[1].each { |a, q: 1| [2].each { |b; q| q = 9; p q }; p q }
p q
