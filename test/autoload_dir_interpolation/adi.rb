# spliced by main: the autoloads name files beside this one through __dir__
module Adi
  autoload :Thing, "#{__dir__}/adi/thing"
  autoload(:Other, "#{__dir__}/adi/other")
  def self.name_of = Thing.name
  def self.late_class = Late
  autoload :Late,  "#{__dir__}/adi/late.rb"
end
