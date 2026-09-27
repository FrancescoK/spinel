module Settings
  attr_accessor :strict
  attr_reader :label
  attr_writer :note

  def describe = "#{label}: strict=#{strict.inspect}"
end

class Machine
  extend Settings
  @strict = false
  @label = "machine"

  def strict? = self.class.strict
end

class Plain
  extend Settings
end

p Machine.strict
p Machine.new.strict?
Machine.strict = true
p Machine.new.strict?
p Machine.describe
Machine.note = "x"
p Plain.strict
p Plain.label
Plain.strict = :yes
p Plain.describe
