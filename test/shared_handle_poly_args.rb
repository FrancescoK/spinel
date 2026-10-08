# A caller's String reaches a method that appends to it through a poly
# receiver. The dispatch used to hand an arm a copy twice over: an arm that
# takes the String by value appended to its own (a name a poly receiver
# reaches kept the value ABI), and beside an argument that runs, a handle
# arm took a fresh handle of the value. A later argument that gives the
# variable another String is the same question for every call: the callee
# appends to the String the argument read. The helper appends LONG, which
# always reallocates.
# spinel: gc-minor
LONG = "." * 100

module Helper
  def self.open_into(io) = (io << "<div>" << LONG; nil)
end
Helper.open_into([]) if ARGV.size > 5   # a second caller makes io POLY

$n = 0
def touch = ($n += 1)
def seen(s) = s.delete(".")

# a handle arm (the helper's pull) and a value arm, the String between
# arguments that run, and a keyword that runs
class Loud
  def pf(k, io, j) = (Helper.open_into(io); io << "loud#{k}#{j}"; nil)
  def kf(io, k:) = (Helper.open_into(io); io << "loudk#{k}"; nil)
end
class Quiet
  def pf(k, io, j) = (io << "quiet#{k}#{j}"; nil)
  def kf(io, k:) = (io << "quietk#{k}"; nil)
end
[Loud.new, Quiet.new].each do |v|
  io = String.new
  v.pf(1, io, 2)
  p seen(io)
  io = String.new
  v.pf(touch, io, touch)
  p seen(io)
  io = String.new
  v.kf(io, k: touch)
  p seen(io)
  io = String.new; keep = io
  v.pf(1, io, (io = String.new; 2))
  p [seen(keep), io]
end

# no arm takes the handle until one appends: every arm takes it
class RoomView
  def view_into(io, n = 0) = (io << "room#{n}"; nil)
end
class UserView
  def view_into(io, n = 0) = (io << "user#{n}" << LONG; nil)
end
[RoomView.new, UserView.new].each do |v|
  io = String.new
  v.view_into(io)
  v.view_into(io, touch)
  p seen(io)
end

# an instance variable as the buffer
class Page
  def initialize = @buf = String.new
  def render
    [Loud.new, Quiet.new].each { |v| v.pf(touch, @buf, touch) }
    p seen(@buf)
  end
end
Page.new.render

# the same rebinding through a direct call, a class method and a subtree
# dispatch into a handle parameter
def dfill(io, k) = (Helper.open_into(io); io << "d#{k}"; nil)
module Kl
  def self.cfill(io, k) = (Helper.open_into(io); io << "c#{k}"; nil)
end
class Base
  def run
    io = String.new; keep = io
    sfill(io, (io = String.new; touch))
    p [seen(keep), io]
  end
  def sfill(io, k) = (io << "base#{k}"; nil)
end
class Sub < Base
  def sfill(io, k) = (Helper.open_into(io); io << "sub#{k}"; nil)
end
a = String.new; keep = a
dfill(a, (a = String.new; touch))
p [seen(keep), a]
a = String.new; keep = a
Kl.cfill(a, (a = String.new; touch))
p [seen(keep), a]
Base.new.run
Sub.new.run
