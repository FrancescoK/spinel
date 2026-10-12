class Transition
  attr_accessor :args

  def initialize(args) = @args = args
end

class Machine
  attr_reader :callbacks

  def initialize = @callbacks = []
  def before(&blk) = @callbacks << blk
  def self.define(&) = new.tap { |m| m.instance_eval(&) }
end

class Vehicle
  attr_accessor :last

  def self.machine = @machine
  @machine = Machine.define { before { |v, t| v.last = t.args } }
end

top = Machine.define { before { |v, t| v.last = [t.args, :top] } }
explicit = Machine.define { self.before { |v, t| v.last = [t.args, :self] } }

[Vehicle.machine, top, explicit].each do |m|
  v = Vehicle.new
  m.callbacks.each { |cb| cb.call(v, Transition.new([:park, 1])) }
  p v.last
end
