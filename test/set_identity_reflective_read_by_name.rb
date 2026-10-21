# An identity Set kept in an instance variable, in a program that reads
# instance variables by names it computes (`instance_variable_get(v)` over a
# list of names) and only inspects what it reads. Such a read may answer
# the Set, so it is followed as a read of the place; used as no Set, it
# leaves the check at the identity Set's own calls, and the plain Set of
# Strings elsewhere is not refused. A reflective write of no Set to a
# computed name is fine too.
require "set"

class Visits
  def initialize = @seen = Set.new.compare_by_identity
  def visit(n) = @seen << n
  def seen?(n) = @seen.include?(n)
  def count = instance_variable_get(:@seen).size
  def note(name) = instance_variable_set(name, 3)
end

module Shown
  def show = shown_ivars.map { |v| "#{v}=#{instance_variable_get(v).inspect}" }.join(" ")
  def shown_ivars = [(:@a unless @a.nil?), (:@b if @b)].compact
end

class Item
  include Shown
  def initialize = (@a = 1; @b = "x")
end

v = Visits.new
a = Item.new
v.visit(a)
v.visit(a)
p v.seen?(a), v.seen?(Item.new), v.count
v.note([:@notes].first)
p Item.new.show

tags = Set.new
tags << "red"
p tags.include?("red"), tags.include?("blue")
