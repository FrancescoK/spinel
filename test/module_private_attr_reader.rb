# An attr_reader a module makes private stays private in a class that
# includes it: it was callable from outside (#8201).
module Secretive
  attr_reader :secret
  private :secret
  def show = secret
end
class Box
  include Secretive
  def initialize = (@secret = 1)
end
begin
  p Box.new.secret
rescue NoMethodError => e
  puts e.message
end
p Box.new.show
