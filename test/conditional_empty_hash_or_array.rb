x = rand(2) < 5 ? {} : []
p x.class, x
y = ARGV.empty? ? [] : {}
p y.class, y
z = ARGV.empty? ? Hash.new : Array.new
p z
def pick(f) = f ? {} : []
p pick(true), pick(false)
