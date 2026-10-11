# A Singleton instance dumps as an empty string and the class loads it
# back as its one instance, the hooks Marshal uses.
require "singleton"

class Conf
  include Singleton

  attr_accessor :level
end

Conf.instance.level = 3
p Conf.instance._dump
p Conf._load("").equal?(Conf.instance)
p Conf._load("").level
