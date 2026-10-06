# A module's included hook that runs a string class_eval in the includer
# (`base.class_eval do class_eval "..." end`, the shape a class-level
# accessor takes when written as code): the code is the includer's, as if
# its class body ran it.
module Silence
  def self.included(base)
    base.class_eval do
      class_eval "@@silencer = true; def self.silencer = @@silencer; def silencer = @@silencer"
      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        def self.quiet? = !silencer
      RUBY
    end
  end
end

class Log
  include Silence
end

class Other
  include Silence
end

p Log.silencer, Log.new.silencer, Log.quiet?
p Other.silencer
