# frozen_string_literal: true
require_relative 'spread_sends'

class Handler
  def step(*values) = values.sum
  def finalize = :done
  def call(*args) = args.empty? ? nil : args
  def both(a, b) = [b, a]
end

t = CextSpread::Tracker.new
t.handler = Handler.new
p t.send_to(:step, 1, 2, 3)
p t.send_to(:step)
p t.send_to(:finalize)
p t.send_to(:both, :x, :y)
p t.calls
p t.apply(:both, [1, 2])
p t.apply(:step, [])
begin
  t.send_to(:missing, 1)
rescue NoMethodError => e
  p e.class
end

p CextSpread.scan_args(1)
p CextSpread.scan_args(1, 2)
p CextSpread.scan_args(1, 2, 3, 4)
p CextSpread.scan_args(1) { |x| x * 10 }
p CextSpread.scan_opt
p CextSpread.scan_opt(5)
begin
  CextSpread.scan_args
rescue ArgumentError => e
  p e.message
end
begin
  CextSpread.scan_opt(1, 2, 3)
rescue ArgumentError => e
  p e.message
end

w, inst, back = CextSpread.wrap(Handler.new)
p w.class == inst.class
p w.class.superclass
p back.class
p w.instance_variables
GC.start
p CextSpread.wrap(Handler.new)[2].class
