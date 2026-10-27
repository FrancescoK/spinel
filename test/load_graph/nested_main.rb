# Nested requires run each file's top level once, at its first require, in
# CRuby's order; a require of a file whose load is under way answers false.
puts "main start"
require_relative "nested_a"
require_relative "nested_a"
require_relative "nested_b"
puts "main end"
