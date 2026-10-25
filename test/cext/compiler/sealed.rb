# frozen_string_literal: true
require_relative 'sealed'

sealed = CextSealed.make(5)
p sealed.class
p sealed.value
p CextSealed.make(-2).value
[-> { CextSealed.new }, -> { CextSealed.allocate }, -> { sealed.dup }, -> { sealed.clone }].each do |make|
  make.call
rescue TypeError => e
  p e.message
end
GC.start
p sealed.value
