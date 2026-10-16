# spinel: share
# A yielding method's block parameter holds a String stored under :name,
# and the Hash is then mutated through :dirs, which is given that String too
# (`options[:dirs] = options[:name]`): the mutation reaches the stored
# parameter's String. Every yield hands the block a new String, so the
# parameter's String is a handle nothing else holds (#9196); it was refused
# before.
def each_opt
  yield "a" + ""
end
options = { dirs: [] }
each_opt { |v| options[:name] = v }
options[:dirs] = options[:name]
options[:dirs] << "x"
p options
