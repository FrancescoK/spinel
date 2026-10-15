# frozen_string_literal: true
# The runtime's display, comparison and hashing hooks reach C methods.
require_relative 'display'
a = CextPoint.new(2)
b = CextPoint.new(1)
puts a
p a
puts "#{a} and #{b}"
puts a.inspect
p [a, b]
p [a, b].sort.map(&:to_s)
puts [a, b].min
p({ CextPoint.new(1) => :one }[b])
p [a, b, CextPoint.new(2)].uniq.size
