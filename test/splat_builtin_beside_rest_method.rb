# A splat into a builtin whose name a user method also takes with *rest:
# every element reaches the builtin, and the user method still gets them all.
class Recorder
  def index(*a) = a
  def count(x, *rest) = [x, rest]
  def start_with?(*a) = a
  def split(*a) = a
  def fetch(*a) = a
end

def idx(s, *a) = s.index(*a)
def cnt(s, *a) = s.count(*a)
def sw(s, *a) = s.start_with?(*a)
def sp(s, *a) = s.split(*a)
def fe(h, *a) = h.fetch(*a)
def idx_from(s, *a) = s.index("b", *a)
def idx_str(s, *a) = s.index(*a)
def fe_hash(h, *a) = h.fetch(*a)

p idx("abcb", "b", 2)
p idx("abcb", "b")
p idx_from("abcb", 2)
p cnt("banana", "a", "n")
p cnt("banana", "a")
p sw("abc", "x", "ab")
p sw("abc", "x")
p sp("a,b,c", ",", 2)
p sp("a,b,c", ",")
p fe({ a: 1 }, :z, 0)
p fe({ a: 1 }, :a)
p fe([10, 20], 5, :none)
begin
  idx_str("abcb")
rescue ArgumentError => e
  puts e.message
end
begin
  fe_hash({ a: 1 })
rescue ArgumentError => e
  puts e.message
end

r = Recorder.new
p idx(r, 1, 2, 3)
p idx(r)
p cnt(r, 1, 2, 3)
p fe(r, 1, 2, 3, 4, 5, 6, 7, 8)
# a splat of a call's result keeps its splat call, any length
p r.fetch(*(1..12).to_a)

[r, "abcb"].each { |x| p idx(x, "b", 2) }

# def_delegators defines `def m(*args)` forwarding a splat
require "forwardable"
class Words
  extend Forwardable
  def_delegators :@s, :index, :rindex, :count, :start_with?, :end_with?, :split
  def initialize(s) = @s = s
end
w = Words.new("abcb")
p w.index("b", 2)
p w.rindex("b", 2)
p w.count("a", "b")
p w.start_with?("x", "ab")
p w.end_with?("x", "cb")
p w.split("b", 2)
