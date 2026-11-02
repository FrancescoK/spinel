module Codes
  class Base; end
  Names = { 1 => "One" }
  Names.each { |code, name| const_set(name, Class.new(Base)) }
end
class One
  def self.tag = :top
end
p Codes::One.superclass, One.tag
