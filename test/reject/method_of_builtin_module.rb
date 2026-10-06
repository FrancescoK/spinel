# A Method object of a builtin module's function has no compiled function to
# bind. ENV, FileTest and Marshal, which are modeled only as call receivers,
# cast their constant to a pointer and the C did not build; Math, Process or
# String built a Method that raised NoMethodError when called. It is refused
# at the call, naming it (core/env/each_spec, filetest/zero_spec).
p ENV.method(:each) == ENV.method(:each_pair)
