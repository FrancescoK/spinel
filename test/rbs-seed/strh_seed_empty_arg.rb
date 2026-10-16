# Parameters an --rbs signature gives Array[String], handed an empty Array
# (`[]` or Array.new, also as a keyword's value) while the Strings of the
# Arrays they are handed are changed in place: under --share-strings the
# Array of String handles is the form of such a parameter, and an empty
# literal bound to it has no element to type it, so it was built as an
# Integer Array the parameter's C type does not take. The class of the
# parameter keeps the general Array instead.
module SeedEmptyArg
  def self.check(fields, scalars, hashes)
    fields[0] << "!" if fields.size > 0
    scalars[0] << "?" if scalars.size > 0
    hashes[0] << "." if hashes.size > 0
    fields.size + scalars.size + hashes.size
  end

  def self.named(names:)
    names[0] << "#" if names.size > 0
    names.size
  end
end

class SeedEmptyArgCtl
  def initialize(names, extra)
    @names = names
    @extra = extra
  end

  def run
    @names[0] << "!" if @names.size > 0
    @extra[0] << "?" if @extra.size > 0
    @names.size + @extra.size
  end

  def names = @names
end

names = [+"title", +"body"]
more = [+"m"]
p SeedEmptyArg.check(names, [], [])
p SeedEmptyArg.check([], more, [])
p SeedEmptyArg.check(Array.new, [], more)
p SeedEmptyArg.check([+"x"], [+"y"], [+"z"])
p SeedEmptyArg.named(names: [])
p names, more

ctl = SeedEmptyArgCtl.new(names, [])
p ctl.run
p SeedEmptyArgCtl.new([], more).run
p SeedEmptyArgCtl.new(Array.new, []).run
p ctl.names, more
