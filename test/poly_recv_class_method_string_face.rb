# A value that is a String or a module answers a String method's name
# from the module's own class method when it is the module: `chars` and
# `bytes` here went to the String method on a boxed receiver, whichever it
# held, and the module raised NoMethodError.
module M
  def self.chars = ["m"]
end
module N
  def self.bytes = [7]
end
h = {a: "x,y", b: M}
p h[:a].chars
p h[:b].chars
g = {a: "hi", b: N}
p g[:a].bytes
p g[:b].bytes
