# push / unshift with keywords on a value that may be an Array or an object
# of a class with its own push: the Array takes the keywords as one Hash

class S
  def push(static:) = static
  def unshift(a, k: 0) = [a, k]
  def <<(x) = x
end

def recv(arr) = arr ? [] : S.new

r = recv(true)
p r.push(static: true)
p r.push(1, a: 2, "b" => 3)
p recv(false).push(static: :s)

q = ARGV.empty? ? [0] : S.new
p q.unshift(5, k: 1)
p q.unshift(k: 2)
