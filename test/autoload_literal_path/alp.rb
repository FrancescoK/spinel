# spliced by main: autoload with a literal path
module Alp
  autoload :Thing, "alp/thing"
  def self.name_of = Thing.name
end
