require "weakref"

class Conn
  attr_reader :name
  def initialize(name) = @name = name
  def closed? = false
end

refs = []
refs << WeakRef.new(Conn.new("a"))
refs << WeakRef.new(Conn.new("b"))
refs.each do |r|
  p r.weakref_alive?
  p r.__getobj__.name
  p r.__getobj__.closed?
end
p refs[0].__getobj__.name
p WeakRef::RefError.ancestors.include?(StandardError)
p refs[0] == refs[0]
p refs[0] == refs[1]
w = WeakRef.new("str")
p w.__getobj__.upcase
p w.to_s
p w.inspect
w.__setobj__("other")
p w.__getobj__
p WeakRef.new(nil).weakref_alive?
