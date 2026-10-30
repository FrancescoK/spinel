# A target loaded from a method has no fixed order against its alias.
# The alias keeps the method table's current definition in either load model.
def boot
  require_relative 'fixtures/alias_record/body'
end
boot
class Timer
  alias_method :delay, :delay=
end
p Timer.new.delay(10)
