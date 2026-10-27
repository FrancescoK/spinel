# A method defined twice in a program that loads nothing it has not read:
# the word in this comment, `load "plugins.rb"`, runs no file, so the
# record's dump (record_versions_comment_main.rb.load-record) does not
# list the method as named, and its first version's interval holds.
require_relative "record_versions_comment_lib"
module Gauge
  def self.level = 1
end
module Gauge
  def self.level = 2
end
p Gauge.level
p Gauge.unit
