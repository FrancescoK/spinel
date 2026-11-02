Paint = Data.define(:name)
Paint::WHITE = Paint.new("white")
module Tex
  WHITE = 7
  def self.layer = WHITE + 1
end
p Paint::WHITE.name, Tex::WHITE, Tex.layer
