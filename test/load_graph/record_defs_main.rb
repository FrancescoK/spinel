# The load record's histories (--dump-load-record,
# record_defs_main.rb.load-record): method versions with their visibility,
# an alias taking the version live where it stands (a required file's
# include ahead of it), class bodies and mixins in the order they run,
# a singleton method and a hook, and the first writes of a global, main's
# instance variable and a constant.
module Loud
  def say = "loud"
end
class Speaker
  def say = "plain"
  private
  def secret = 1
  public
  attr_accessor :volume
  def self.inherited(k) = nil
end
require_relative "record_defs_lib"
class Speaker
  alias_method :shout, :say
  include Loud
  define_method(:hum) { "hm" }
  protected :secret
  class << self
    def make = new
  end
end
module Util
  module_function
  def twice(x) = x * 2
end
$level = 3
@main_ivar = :set
LIMIT = 10
s = Speaker.make
puts s.shout
puts s.say
puts s.hum
puts Util.twice($level)
puts LIMIT
