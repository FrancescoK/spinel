# A backtick literal is a receiverless call of the method named `, as in
# CRuby. A def of that name (or an alias, alias_method or define_method)
# answers each backtick whose self reaches it. Any other self still runs
# the command, and so do `super` and Kernel.` inside such a method.
# Spinel ran the command for every backtick and ignored the program's own
# method.

class Shell
  def `(cmd) = "Shell ran #{cmd}"
  def run = `ls -l`
  def runs(n) = (1..n).map { |i| %x(job #{i}) }
end

class Plain
  def run = `echo plain`
end

class Recorder
  def self.`(cmd) = "class-level #{cmd}"
  def self.run = `date`
end

module Fake
  def `(cmd) = cmd.upcase
end

class UsesFake
  include Fake
  def run = `build all`
end

class Aliased
  def fake(cmd) = "aliased #{cmd}"
  alias_method :`, :fake
  def run = `pwd`
end

class Defined
  define_method(:`) { |cmd| "defined #{cmd}" }
  def run = `id`
end

class Frozen
  def `(cmd) = cmd.frozen?
  def plain = `x`
  def interp(v) = `x#{v}`
end

class Wrapped
  def `(cmd)
    out = super
    "wrapped #{out}"
  end
  def run = `echo inner`
end

class Logged
  def `(cmd) = "log: " + Kernel.`(cmd)
  def run = `echo logged`
end

class Named
  define_method("`") { |cmd| "string name #{cmd}" }
  def run = `echo n`
end

class Blank < BasicObject
  def `(cmd) = "blank " + super
  def run = `echo blank`
end

p Shell.new.run
p Shell.new.runs(2)
p Plain.new.run
p Recorder.run
p UsesFake.new.run
p Aliased.new.run
p Defined.new.run
p Frozen.new.plain, Frozen.new.interp(1)
p Wrapped.new.run
p Logged.new.run
p Named.new.run
p defined?(`echo never`)
begin
  Blank.new.run
rescue ::NoMethodError => e
  p e.class
end
p `echo top`
