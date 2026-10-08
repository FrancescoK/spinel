# Imported calls also keep their receiver when a top-level name collides.
require "fiddle/import"
def abs(x) = -101
module UnconstrainedLib
  extend Fiddle::Importer
  dlload Fiddle.dlopen(nil)
  ABS = extern "int abs(int)"
  UPPER = extern "int toupper(int)"
  def self.run(obj)
    p obj.instance_eval { abs(97) }
    p obj.instance_exec(97) { |x| abs(x) }
  end
end
class UnconstrainedTable
  include UnconstrainedLib
  def initialize = @func_map = {"abs" => UnconstrainedLib::UPPER}
end
class UnconstrainedMissingTable
  include UnconstrainedLib
end
UnconstrainedLib.run(UnconstrainedTable.new)
UnconstrainedLib.run(UnconstrainedLib)
begin
  UnconstrainedLib.run(UnconstrainedMissingTable.new)
rescue NoMethodError => e
  puts "#{e.class}: #{e.message}"
end
module UnconstrainedLib
  def self.exec(obj) = obj.instance_exec { abs(97) }
end
p UnconstrainedLib.exec(UnconstrainedTable.new)
begin
  UnconstrainedLib.exec(UnconstrainedMissingTable.new)
rescue NoMethodError => e
  puts "#{e.class}: #{e.message}"
end
