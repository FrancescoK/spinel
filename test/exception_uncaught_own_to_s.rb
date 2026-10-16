# An uncaught exception whose class defines only #to_s prints it too: the
# default #message calls #to_s. A `raise Class` carries no object until one is
# needed, and the report needs one.
class ConfigError < StandardError
  def to_s
    "config file not found"
  end
end

puts "before"
raise ConfigError
