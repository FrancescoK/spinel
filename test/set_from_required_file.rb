# `Set` referenced from a required file, never from the entry file, with no
# `require "set"` anywhere: CRuby provides Set without one wherever it is
# used, and the implicit `require "set"` splice used to look at the entry
# file's text only, so the required file's Set.new stopped the build on the
# name without its require (activesupport's notifications/fanout.rb).
require_relative "set_from_required_file/uses_set"

e = Exclusions.new
e.add(:a).add(:b).add(:a)
p e.size
