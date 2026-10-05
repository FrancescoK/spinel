# Shapes beside the refused stored block parameter (a proc's, a lambda's or
# a non-element iterator's parameter stored into a container whose element
# is then mutated): the element is replaced rather than mutated, the value
# is no String, or an element iterator binds the parameter, so each
# compiles and answers as CRuby.
k4 = []
b4 = proc { |i, v| k4[i] = v }
b4.call(0, +"a"); b4.call(1, 2); p k4
k4[0] = k4[0] + "b"; p k4
k5 = []
b5 = proc { |i, v| k5[i] = v }
b5.call(0, [1]); b5.call(1, 2); k5[0] << 3; p k5
k6 = []
b6 = proc { |v| k6 << v }
b6.call(1); b6.call(2.5); k6[0] += 1; p k6
k7 = []
[+"a"].each_with_index { |v, i| k7[i] = v }; k7[0] << "b"; p k7
k8 = []
b8 = proc { |i, v| k8[i] = v.upcase }
b8.call(0, +"a"); k8[0] << "b"; p k8
k9 = []
2.times { |i| k9 << i.to_s }; k9[0] << "!"; p k9
