# The load record's method versions (--dump-load-record,
# record_versions_main.rb.load-record): each replaced version's interval,
# up to the next version; the version its own name reaches over that
# interval (itself, or unknown where a module mixed in between has the
# name too); the versions of the name in every history; and whether the
# program names the method by a Symbol or a String, which lets a version
# run outside its interval (kept, by respond_to?).
require_relative "record_versions_lib"
module Tally
  def self.up(n) = n <= 0 ? 0 : 1 + up(n - 1)
end
module Tally
  def self.up(n) = n <= 0 ? 100 : 10 + up(n - 1)
  def self.kept = :first
end
p Tally.respond_to?(:kept)
module Tally
  def self.kept = :second
end
p Tally.up(3)
p Tally.kept
class Box
  def get = 1
end
class Box
  include Shiny
  def get = 2
end
class Box
  def get = 3
end
p Box.new.get
