# A boxed receiver's call reaches a class method only where the box can
# hold that class's object. A module the program only ever calls (its own
# `self.sub`, `self.split`) is never a value: no box holds it, so a boxed
# String's sub and split answer the String's new Strings alone. Kept beside
# a String changed through another name, each is a new handle, a change
# through it showing through its other names.
$all = []
b = +"buf"; $all << b; b << "!"
module Params
  def self.sub(params, key) = params.fetch(key, {})
end
module ParamBuilder
  def self.split(s, n) = [s.to_s]
end
opts = { protocol: ARGV.size > 0 ? 1 : +"https://", port: 3 }
pr = opts.fetch(:protocol, "http").sub("://", "")
$all << pr
pr << "?"
def lookup(string)
  head = string.split(";", 2)[0]
  $all << head
  head
end
h = lookup(ARGV.size > 0 ? 1 : +"text/html; charset=utf-8")
h << "?"
p pr, h, Params.sub({ "a" => 1 }, "a"), ParamBuilder.split("x", 1)
p $all
