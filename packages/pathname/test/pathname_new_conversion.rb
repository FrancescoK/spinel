require "pathname"

def check_path(label, value)
  puts "#{label}: #{Pathname.new(value).to_s.inspect}"
rescue TypeError => e
  puts "#{label}: #{e.class}: #{e.message}"
rescue ArgumentError => e
  puts "#{label}: #{e.class}: #{e.message}"
end

class PathArgument
  def to_path
    "from_path"
  end

  def to_str
    "from_str"
  end
end

class StringArgument
  def to_str
    "from_str"
  end
end

class DisplayArgument
  def to_s
    "display_only"
  end
end

class InvalidPathArgument
  def to_path
    nil
  end
end

class InvalidStringArgument
  def to_str
    42
  end
end

class PathConversionError < TypeError
end

class RaisingPathArgument
  def initialize(fail)
    @fail = fail
  end

  def to_path
    raise PathConversionError, "conversion failed" if @fail
    "from_path"
  end
end

check_path("string", "a/b")
check_path("empty", "")
check_path("pathname", Pathname.new("a/b"))
check_path("to_path first", PathArgument.new)
check_path("to_str", StringArgument.new)
check_path("nil", nil)
check_path("integer", 0)
check_path("true", true)
check_path("false", false)
check_path("to_s only", DisplayArgument.new)
check_path("invalid to_path", InvalidPathArgument.new)
check_path("invalid to_str", InvalidStringArgument.new)
check_path("raising to_path", RaisingPathArgument.new(true))
check_path("null byte", "a\0b")

source = String.new("original")
path = Pathname.new(source)
source.replace("changed")
puts "copied: #{path}"
