# A Set takes any member in a program whose only compare_by_identity is a
# class's own method reached by a computed name: the dispatch over every
# name the program defines (a send's or method()'s arm, or a method(name)
# wrapper) called compare_by_identity on a boxed receiver, which counted as
# making a Set an identity one and refused every boxed member (Rack::Headers
# defines compare_by_identity; Zeitwerk and Rails reach methods by name).
require "set"

class Headers
  def compare_by_identity = raise(TypeError, "Headers cannot compare by identity")
  def size = 0
end

def boxed(x) = x
def ask(o, name) = o.method(name).call
def via_send(o, name) = o.send(name)

name = [:size, ("compare_by" + "_identity").to_sym][0]
p ask(boxed([[1, 2], Headers.new][0]), name)
p via_send(boxed([[1, 2, 3], Headers.new][0]), name)

s = Set.new
s << "a"
s << boxed([1, "b"][0])
p s.size, s.include?("a"), s.include?(1)
