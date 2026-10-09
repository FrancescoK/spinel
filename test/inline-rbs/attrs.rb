# Inline RBS attribute and instance-variable declarations. Each ivar is only
# ever assigned nil, so inference alone leaves it boxed (sp_RbVal); a `String?`
# declaration pins it to a `const char *` field. Compiled with
# `--no-inline-rbs --rbs sig/attrs` the program must produce the same C.

class Label
  attr_reader :trailing #: String?

  #: String?
  attr_accessor :leading

  # @rbs @declared: String?

  def initialize
    @trailing = nil
    @leading = nil
    @declared = nil
    @assigned = nil #: String?
    @plain = nil
  end

  def declared
    @declared
  end

  def assigned
    @assigned
  end

  def plain
    @plain
  end
end

l = Label.new
p l.trailing
p l.leading
p l.declared
p l.assigned
p l.plain
