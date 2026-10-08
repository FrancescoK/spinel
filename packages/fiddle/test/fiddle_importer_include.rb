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
