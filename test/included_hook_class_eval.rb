# `include M` runs M.included(base): base.class_eval { ... } shapes the
# includer, and other uses of base name it.
module Layouts
  def self.included(base)
    puts "included in #{base}"
    base.class_eval do
      setup :socket, :fd
    end
    base.extend(Helpers)
  end
end
module Helpers
  def describe = "fields: #{fields.inspect}"
end
class Base
  def self.setup(*f) = @fields = f
  def self.fields = @fields
end
class PollItem < Base
  include Layouts
end
p PollItem.fields
p PollItem.describe
