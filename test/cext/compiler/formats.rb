# frozen_string_literal: true
require_relative 'formats'

class FormatsToken
  def inspect = "#<token>"
end
p CextFormats::VERSION
p CextFormats.items([3, 4])
[7, "text", :sym, nil, [1, "a"], {b: 2}, 2.5, FormatsToken.new].each do |value|
  CextFormats.fail_with(value)
rescue TypeError => e
  p e.message
end
