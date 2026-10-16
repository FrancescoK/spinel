# A module method's `rescue X => e` arm, run in the class that includes,
# extends or prepends the module: the arm's value is the method's, as it
# is for a method the class defines itself.
class Lookup
  def self.find
    raise NameError, "no such entry"
    nil
  end
end

module Probe
  def probe
    raise NameError, "probe failed"
  rescue NameError => e
    e.message
  end

  def via_class
    Lookup.find
  rescue NameError => e
    "#{e.class}: #{e.message}"
  end
end

class Included
  include Probe
end

class Extended
  extend Probe
end

class Prepended
  prepend Probe
end

p Included.new.probe, Included.new.via_class
p Extended.probe
p Prepended.new.probe
puts Included.new.probe.upcase

# A user exception that carries a field, read from the binding.
class CodeError < StandardError
  attr_reader :code

  def initialize(code)
    @code = code
    super("code #{code}")
  end
end

module Coded
  def code_of
    raise CodeError.new(7)
  rescue CodeError => e
    e.code + 1
  end
end

class Worker
  include Coded
end

p Worker.new.code_of

# is_a? on a caught exception, with a namespaced class beside a top-level
# one of the same name.
module Storage
  class WriteError < StandardError
    attr_reader :code

    def initialize(code)
      @code = code
      super("write #{code}")
    end
  end
end

class WriteError < StandardError
end

class Disk
  def check
    yield
  rescue => e
    [e.is_a?(Storage::WriteError), e.is_a?(WriteError)]
  end
end

p Disk.new.check { raise Storage::WriteError, 3 }
p Disk.new.check { raise WriteError, "top" }
