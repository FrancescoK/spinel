# Imported module functions use the calling receiver's function table.
require "fiddle/import"
module M
  extend Fiddle::Importer
  dlload Fiddle.dlopen(nil)
  ABS = extern "int abs(int)"
  UPPER = extern "int toupper(int)"
  p abs(-1)
  def self.a(x) = abs(x)
  def self.b(x) = self.abs(x)
  class << self
    def c(x) = abs(x)
  end
  def inherited(x) = abs(x)
end
class U
  include M
  def a(x) = abs(x)
end
p M.abs(-3), M.a(-4), M.b(-5), M.c(-6)
begin
  U.new.a(-3)
rescue NoMethodError => e
  puts "#{e.class}: #{e.message}"
end
begin
  U.new.inherited(-6)
rescue NoMethodError => e
  puts "#{e.class}: #{e.message}"
end

# A receiver that supplies a function table can use the private method.
class WithTable
  include M
  def initialize(fn = M::ABS) = @func_map = {"abs" => fn}
  def a(x) = abs(x)
end
p WithTable.new.a(-7)
p WithTable.new(M::UPPER).a(97)

begin
  M.nothere(1)
rescue NoMethodError
  puts "NoMethodError"
end

# Blocks that replace self must use the new receiver's table, including when
# one singleton method is called with both instances and the module itself.
module M
  def self.eval_abs(obj) = obj.instance_eval { abs(97) }
  def self.exec_abs(obj) = obj.instance_exec(abs(-97)) { |x| abs(x) }
  def self.class_eval_abs = M.class_eval { abs(-8) }
  def self.module_eval_abs = M.module_eval { abs(-9) }
  define_method(:defined_abs) { abs(97) }
  define_singleton_method(:singleton_abs) { abs(-10) }
end

def report_fiddle
  p yield
rescue NoMethodError => e
  puts "#{e.class}: #{e.message}"
end

report_fiddle { M.eval_abs(U.new) }
report_fiddle { M.eval_abs(WithTable.new(M::UPPER)) }
report_fiddle { M.eval_abs(M) }
report_fiddle { M.exec_abs(U.new) }
report_fiddle { M.exec_abs(WithTable.new(M::UPPER)) }
report_fiddle { M.exec_abs(M) }
report_fiddle { U.new.defined_abs }
report_fiddle { WithTable.new(M::UPPER).defined_abs }
p M.class_eval_abs, M.module_eval_abs, M.singleton_abs

# The same receiver changes can occur directly in the importing module body.
module M
  report_fiddle { U.new.instance_eval { abs(-1) } }
  report_fiddle { WithTable.new(UPPER).instance_eval { abs(97) } }
  report_fiddle { M.instance_eval { abs(-11) } }
  report_fiddle { U.new.instance_exec { abs(-1) } }
  report_fiddle { WithTable.new(UPPER).instance_exec { abs(97) } }
  report_fiddle { M.instance_exec { abs(-12) } }
  p M.class_eval { abs(-13) }, M.module_eval { abs(-14) }
end

# class_eval and module_eval rebind self to a class or module object.
module EmptyModuleTable
  include M
  extend M
end
module OwnModuleTable
  include M
  extend M
  @func_map = {"abs" => M::UPPER}
end
module M
  report_fiddle { EmptyModuleTable.class_eval { abs(97) } }
  report_fiddle { OwnModuleTable.class_eval { abs(97) } }
  report_fiddle { EmptyModuleTable.module_eval { abs(97) } }
  report_fiddle { OwnModuleTable.module_eval { abs(97) } }
end

# A module-only receiver keeps a class value through the table lookup.
def module_table(obj) = obj.instance_variable_get(:@func_map)
p module_table(M)["abs"].call(-15)
def module_eval_self(obj) = obj.instance_eval { self }
def module_exec_self(obj) = obj.instance_exec { self }
p module_eval_self(M).equal?(M), module_exec_self(M).equal?(M)
