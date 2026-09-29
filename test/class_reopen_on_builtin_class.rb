module CM
  def sm = (@sm ||= superclass.respond_to?(:sm) ? superclass.sm.dup : [])
end

module CT
  def st = (@st ||= superclass ? superclass.st.dup : [])
end

class Class
  include CM
  include CT

  def greet(who, punct = "!") = "#{name} greets #{who}#{punct}"

  def each_sm
    sm.each { |x| yield x }
  end

  def each_tag(n)
    n.times { |i| yield "#{name}#{i}" }
  end
end

class V; end
class W < V; end

p V.superclass.respond_to?(:sm)
p BasicObject.superclass.respond_to?(:sm)
p V.sm
W.sm << :w
p W.sm
p V.sm
p Object.sm
p String.sm
p BasicObject.sm
p Object.superclass
p BasicObject.superclass
p V.st
p Object.st
p BasicObject.st
p(BasicObject.superclass ? 1 : 2)
p(!BasicObject.superclass)
p(!!Object.superclass)
k = BasicObject.superclass
p(k || String)
p(k && 4)
p(Object.superclass && 4)
puts "no superclass" unless k
p String.greet("x")
p Integer.greet("y", "?")
p StandardError.greet("z")
Object.each_sm { |x| p x }
W.each_sm { |x| p x }

[String, 1, V, :s, Hash].each do |o|
  p o.greet("poly") if o.is_a?(Class)
end

def greet_all(k) = k.greet("dyn")
p greet_all(Array)
p greet_all(W)
def tags_of(k) = k.each_tag(2) { |x| p x }
tags_of(Float)
tags_of(W)
begin
  greet_all(Comparable)
rescue NoMethodError => e
  p e.class
end

class Class
  p greet("body")
end
