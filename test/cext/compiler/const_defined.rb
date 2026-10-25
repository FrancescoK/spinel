# frozen_string_literal: true
module CextDefinedOuter
  def self.ruby_side = :ruby
end
require_relative 'const_defined'

p CextDefinedOuter.answer
p CextDefinedOuter.ruby_side
p CextDefinedOuter::STRING_DEFINED
p CextDefinedOuter::MISSING_DEFINED
p CextDefinedOuter::INNER_BEFORE
p CextDefinedOuter::INNER_AFTER
p CextDefinedOuter::Inner.superclass
