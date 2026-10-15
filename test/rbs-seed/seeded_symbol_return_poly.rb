# A method seeded `-> Symbol` whose body answers a boxed value: the value
# is unboxed into the Symbol return, as a seeded String or object return
# is. The box was handed back through the sp_sym signature and the C did
# not build (#9221).
class ModePicker
  def initialize
    @opts = { "mode" => :fast }
    @opts["level"] = 1
  end

  def pick
    @opts["mode"] || :fallback
  end

  def pick_missing
    @opts["other"] || :fallback
  end
end

class ModeSettings
  def self.mode=(value)
    @mode = value.to_s.to_sym
  end

  def self.mode
    @mode
  end
end

class ModeApplier
  def apply(opts)
    ModeSettings.mode = opts["mode"] || :fallback
  end
end

picker = ModePicker.new
p picker.pick
p picker.pick_missing
applier = ModeApplier.new
p applier.apply({ "mode" => :slow, "level" => 1 })
p applier.apply({ "level" => 1 })
p ModeSettings.mode
