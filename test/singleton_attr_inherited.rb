# A `class << self; attr_accessor` is a method of the singleton class, and a
# subclass's singleton class inherits it: the accessor is reachable through
# the subclass, with the subclass's own slot (nil until it is assigned),
# and an inherited class method reading it bare reads the receiver's slot
# (tzinfo's TimeWithOffset.zone through Time.zone_default).
class Base
  class << self
    attr_accessor :zone_default
    attr_writer :region
    def zone = @zone || zone_default
    def region_or(dflt) = @region || dflt
  end
end
class Sub < Base; end
class Own < Base
  class << self
    attr_accessor :zone_default
  end
end

Base.zone_default = "UTC"
p Base.zone, Base.zone_default
p Sub.zone, Sub.zone_default
Sub.zone_default = "JST"
p Sub.zone, Sub.zone_default, Base.zone
Sub.region = "asia"
p Sub.region_or("none"), Base.region_or("none")
Own.zone_default = "CET"
p Own.zone, Base.zone_default
p Sub.respond_to?(:zone_default), Sub.respond_to?(:zone_default=), Sub.respond_to?(:region)
