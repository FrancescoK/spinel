# An object a computed call answers (a send by a name only the run time knows)
# reaches its reader's Array, and what is pushed through that reader is in
# the Array: a block over its elements dispatches to the pushed class's
# methods (#9777, LangArena's NeuralNet)
class Synapse
  attr_accessor :weight, :prev_weight
  def initialize = (@prev_weight = @weight = 0.5)
end
class Neuron
  attr_accessor :synapses_out
  def initialize = (@synapses_out = [])
  def total = synapses_out.reduce(0.0) { |sum, s| sum + s.prev_weight }
end
class Maker
  def neuron = Neuron.new
end
source = Maker.new.send((ARGV[0] || "neuron").to_sym)
source.synapses_out << Synapse.new
source.synapses_out << Synapse.new
p source.total
