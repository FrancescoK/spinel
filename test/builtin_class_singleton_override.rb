# spinel: share
# spinel: gc-minor
# Builtin class and module emitters defer to the resolved user singleton.
# A user method may also accept arguments different from the builtin's.
class Dir
  def self.exist?(value) = "dir:#{value}"
  def self.glob(value) = "glob:#{value}"
  def self.empty?(value) = "empty:#{value}"
end
class IO
  def self.sysopen(value) = "io:#{value}"
  def self.read(value) = "read:#{value}"
end
module FileTest
  def self.file?(value) = "filetest:#{value}"
end
module Process
  def self.pid = "process"
end
module Math
  def self.sqrt(value) = "math:#{value}"
end
class Time
  def self.at(value) = "time:#{value}"
end
class Regexp
  def self.escape(value) = value + 10
end
module GC
  def self.count = "gc"
end
class Thread
  def self.current = "thread"
end
class Random
  def self.rand(value) = "random:#{value}"
end
module Marshal
  def self.dump(value) = "marshal:#{value}"
end
p Dir.exist?("x")
p Dir.glob("x")
p Dir.empty?("x")
p IO.sysopen("x")
p FileTest.file?("x")
p Process.pid
p Math.sqrt("x")
p Time.at("x")
p Regexp.escape(3)
p GC.count
p Thread.current
p Random.rand("x")
p Marshal.dump("x")

# Builtin rewrites and block parameter rules also respect user targets.
class File
  def self.open(value)
    yield value + 1
  end
  def self.foreach(value)
    yield value + 2
  end
  def self.new(value) = value + 3
end
class Time
  def self.new(value) = value + 4
end
p IO.read("x")
p File.open(4) { |value| value * 2 }
p File.foreach(4) { |value| value * 3 }
p File.new(4)
p Time.new(4)

# Conversion and constructor arms use the same resolved target.
class Array
  def self.try_convert(value) = "array:#{value}"
end
class Integer
  def self.try_convert(value) = "integer:#{value}"
end
class String
  def self.try_convert(value) = "string:#{value}"
end
class Hash
  def self.try_convert(value) = "hash:#{value}"
  def self.new(*args, **kw) = "hash-new:#{args.size}:#{kw.size}"
end
class Rational
  def self.sqrt(value) = "rational:#{value}"
end
class Proc
  def self.new = "proc-new"
end
module Kernel
  def self.sleep(value) = "sleep:#{value}"
end
p Array.try_convert(3)
p Integer.try_convert(3)
p String.try_convert(3)
p Hash.try_convert(3)
p Hash.new
p Hash.new(4, capacity: 5)
p Rational.sqrt(4)
p Proc.new { 7 }
p Kernel.sleep(0)
